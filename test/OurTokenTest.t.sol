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

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        // ourToken.transfer(alice, transferAmount);
        // Transfer function automatically sets alice as the default sender

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferFailsIfInsufficientBalance() public {
        vm.prank(alice); // alice has 0 tokens
        vm.expectRevert();
        ourToken.transfer(bob, 1 ether);
    }

    function testTransferFromFailsIfNoAllowance() public {
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 10 ether);
    }

    function testTransferFromFailsIfAllowanceTooLow() public {
        vm.prank(bob);
        ourToken.approve(alice, 5 ether);

        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 10 ether);
    }

    function testApproveEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, 123 ether);

        vm.prank(bob);
        ourToken.approve(alice, 123 ether);
    }

    function testReApproveOverwritesPreviousAllowance() public {
        vm.prank(bob);
        ourToken.approve(alice, 10 ether);

        vm.prank(bob);
        ourToken.approve(alice, 20 ether);

        assertEq(ourToken.allowance(bob, alice), 20 ether);
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
