// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "script/DeployBox.s.sol";
import {UpgradeBox} from "script/UpgradeBox.s.sol";
import {BoxV1} from "src/BoxV1.sol";
import {BoxV2} from "src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public proxy;
    address public OWNER = makeAddr("OWNER");

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run(); // right now point to BoxV1
    }

    function testProxyStartsWithV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(10);
    }

    function testUpgrade() public {
        BoxV2 newBox = new BoxV2();

        upgrader.upgradeBox(proxy, address(newBox));

        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).version());

        BoxV2(proxy).setNumber(7);
        assertEq(7, BoxV2(proxy).getNumber());
    }
}