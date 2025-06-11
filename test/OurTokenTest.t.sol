// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;
    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testbobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }
}
