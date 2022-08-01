//
//  AccountsResolver.swift
//  FCL
//
//  Created by Andrew Wang on 2022/7/26.
//

import Foundation
import FlowSDK
import Cadence

final class AccountsResolver: Resolver {

    func resolve(ix: Interaction) async throws -> Interaction {
        if ix.tag == .transaction {
            return try await collectAccounts(ix: ix, accounts: Array(ix.accounts.values))
        }

        return try await withCheckedThrowingContinuation { continuation in
            continuation.resume(with: .success(ix))
        }
    }

    func collectAccounts(ix: Interaction, accounts: [SignableUser]) async throws -> Interaction {
        guard let currentUser = fcl.currentUser,
              currentUser.loggedIn else {
            throw FCLError.unauthenticated
        }

        guard let service = try fcl.serviceOfType(type: .preAuthz) else {
            throw FCLError.preAuthzNotFound
        }

        let preSignable = ix.buildPreSignable(role: Role())
        guard let data = try? JSONEncoder().encode(preSignable) else {
            throw FCLError.encodeFailed
        }

        // for blocto pre-authz it will response approved once request.
        let authnResponse = try await fcl.polling(service: service, data: data)

        let signableUsers = buildSignableUsers(resp: authnResponse)
        var accounts = [String: SignableUser]()

        var newIX = ix
        newIX.authorizations.removeAll()
        signableUsers.forEach { user in
            let tempId = user.tempId

            if accounts.keys.contains(tempId) {
                accounts[tempId]?.role.merge(role: user.role)
            }
            accounts[tempId] = user

            if user.role.proposer {
                newIX.proposer = tempId
            }

            if user.role.payer {
                newIX.payer = tempId
            }

            if user.role.authorizer {
                newIX.authorizations.append(tempId)
            }
        }
        newIX.accounts = accounts
        return newIX
    }

    func buildSignableUsers(resp: AuthResponse) -> [SignableUser] {
        var axs = [(role: RoleType, service: Service)]()
        if let proposer = resp.data?.proposer {
            axs.append((RoleType.proposer, proposer))
        }
        for az in resp.data?.payer ?? [] {
            axs.append((RoleType.payer, az))
        }
        for az in resp.data?.authorization ?? [] {
            axs.append((RoleType.authorizer, az))
        }

        return axs.compactMap { role, service in

            guard let address = service.identity?.address,
                  let keyId = service.identity?.keyId else {
                return nil
            }

            return SignableUser(
                address: Cadence.Address(hexString: address),
                keyId: keyId,
                role: Role(
                    proposer: role == .proposer,
                    authorizer: role == .authorizer,
                    payer: role == .payer,
                    param: nil
                )
            ) { data in
                try await fcl.polling(service: service, data: data)
            }
        }
    }

}
