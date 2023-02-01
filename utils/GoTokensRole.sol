// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Foodies Roles
 * @author goBlockchain
 *
 * @notice Defines roles used in the 36X Games contract. The hierarchy of roles and powers
 *  of each role are described below.
 *
 *  Roles:
 *
 *    DEFAULT_ADMIN_ROLE
 *      | -> May add or remove users from any of the below roles it manages.
 *      |
 *      +-- MINTER_ROLE
 *           -> May mint to any address as long as mint supply has not been met.
 */
contract GoTokensRoles is AccessControl {

    bytes32 public immutable MINTER_ROLE = keccak256("MINTER_ROLE");
    constructor(address admin, address minter) {
        // Assign roles.
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
    }
}