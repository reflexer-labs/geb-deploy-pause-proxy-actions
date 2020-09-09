pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./GebDeployPauseProxyActions.sol";
import {GebDeployTestBase} from "geb-deploy/test/GebDeploy.t.base.sol";
import {DSProxyFactory, DSProxy} from "ds-proxy/proxy.sol";
import {OracleLike} from "geb/OracleRelayer.sol";

contract ProxyCalls {
    DSProxy proxy;
    address proxyActions;

    function modifyParameters(address, address, address, bytes32, uint) public {
        proxy.execute(proxyActions, msg.data);
    }

    function modifyParameters(address, address, address, bytes32, address) public {
        proxy.execute(proxyActions, msg.data);
    }

    function modifyParameters(address, address, address, bytes32, bytes32, uint) public {
        proxy.execute(proxyActions, msg.data);
    }

    function modifyParameters(address, address, address, bytes32, bytes32, address) public {
        proxy.execute(proxyActions, msg.data);
    }

    function modifyParameters(address, address, address, bytes32, uint256, uint256, address) public {
        proxy.execute(proxyActions, msg.data);
    }

    function modifyParameters(address, address, address, bytes32, uint256, uint256) public {
        proxy.execute(proxyActions, msg.data);
    }

    function modifyTwoParameters(
      address,
      address,
      address,
      address,
      bytes32,
      bytes32,
      bytes32,
      bytes32,
      uint,
      uint
    ) public {
      proxy.execute(proxyActions, msg.data);
    }

    function modifyTwoParameters(
      address,
      address,
      address,
      address,
      bytes32,
      bytes32,
      uint,
      uint
    ) public {
      proxy.execute(proxyActions, msg.data);
    }

    function removeAuthorizationAndModify(
      address,
      address,
      address,
      address,
      bytes32,
      uint
    ) public {
      proxy.execute(proxyActions, msg.data);
    }

    function addAuthorization(address, address, address, address) public {
        proxy.execute(proxyActions, msg.data);
    }

    function setAuthorityAndDelay(address, address, address, uint) public {
        proxy.execute(proxyActions, msg.data);
    }

    function updateRedemptionRate(address, address, address, bytes32, uint256) public {
        proxy.execute(proxyActions, msg.data);
    }
}

contract GebDeployPauseProxyActionsTest is GebDeployTestBase, ProxyCalls {
    bytes32 collateralAuctionType = bytes32("ENGLISH");

    function setUp() override public {
        super.setUp();
        deployStable(collateralAuctionType);
        DSProxyFactory factory = new DSProxyFactory();
        proxyActions = address(new GebDeployPauseProxyActions());
        proxy = DSProxy(factory.build());
        authority.setRootUser(address(proxy), true);
    }

    function testmodifyParameters() public {
        assertEq(safeEngine.globalDebtCeiling(), 10000 * 10 ** 45);
        this.modifyParameters(address(pause), address(govActions), address(safeEngine), bytes32("globalDebtCeiling"), uint(20000 * 10 ** 45));
        assertEq(safeEngine.globalDebtCeiling(), 20000 * 10 ** 45);
    }

    function testModifyParameters2() public {
        (,,, uint debtCeiling,,) = safeEngine.collateralTypes("ETH");
        assertEq(debtCeiling, 10000 * 10 ** 45);
        this.modifyParameters(address(pause), address(govActions), address(safeEngine), bytes32("ETH"), bytes32("debtCeiling"), uint(20000 * 10 ** 45));
        (,,, debtCeiling,,) = safeEngine.collateralTypes("ETH");
        assertEq(debtCeiling, 20000 * 10 ** 45);
    }

    function testModifyParameters3() public {
        (OracleLike orcl,,) = oracleRelayer.collateralTypes("ETH");
        assertEq(address(orcl), address(orclETH));
        this.modifyParameters(address(pause), address(govActions), address(oracleRelayer), bytes32("ETH"), bytes32("orcl"), address(123));
        (orcl,,) = oracleRelayer.collateralTypes("ETH");
        assertEq(address(orcl), address(123));
    }

    function testModifyParameters4() public {
        assertTrue(address(accountingEngine.protocolTokenAuthority()) == address(0));
        this.modifyParameters(address(pause), address(govActions), address(accountingEngine), bytes32("protocolTokenAuthority"), address(123));
        assertTrue(address(accountingEngine.protocolTokenAuthority()) == address(123));
    }

    function testModifyParameters5And6() public {
        assertTrue(!taxCollector.isSecondaryReceiver(1));
        assertEq(taxCollector.maxSecondaryReceivers(), 0);
        this.modifyParameters(address(pause), address(govActions), address(taxCollector), bytes32("maxSecondaryReceivers"), 2);
        assertEq(taxCollector.maxSecondaryReceivers(), 2);
        this.modifyParameters(address(pause), address(govActions), address(taxCollector), bytes32("ETH"), 100, 10 ** 27, address(this));
        (uint canTakeBackTax, uint taxPercentage) = taxCollector.secondaryTaxReceivers(bytes32("ETH"), 1);
        assertEq(canTakeBackTax, 0);
        assertEq(taxPercentage, 10 ** 27);
        assertTrue(taxCollector.isSecondaryReceiver(1));
        this.modifyParameters(address(pause), address(govActions), address(taxCollector), bytes32("ETH"), 1, 1);
        (canTakeBackTax, taxPercentage) = taxCollector.secondaryTaxReceivers(bytes32("ETH"), 1);
        assertEq(canTakeBackTax, 1);
        assertEq(taxPercentage, 10 ** 27);
    }

    function testModifyTwoParameters1() public {
        (,,, uint debtCeiling, uint debtFloor,) = safeEngine.collateralTypes("ETH");
        assertEq(debtCeiling, 10000 * 10 ** 45);
        assertEq(debtFloor, 0);
        this.modifyTwoParameters(address(pause), address(govActions), address(safeEngine), address(safeEngine), bytes32("ETH"), bytes32("ETH"), bytes32("debtCeiling"), bytes32("debtFloor"), uint(20000 * 10 ** 45), uint(10));
        (,,, debtCeiling, debtFloor,) = safeEngine.collateralTypes("ETH");
        assertEq(debtCeiling, 20000 * 10 ** 45);
        assertEq(debtFloor, 10);
    }

    function testModifyTwoParameters2() public {
        assertEq(safeEngine.globalDebtCeiling(), 10000 * 10 ** 45);
        assertEq(accountingEngine.surplusAuctionAmountToSell(), 0);
        this.modifyTwoParameters(address(pause), address(govActions), address(safeEngine), address(accountingEngine), bytes32("globalDebtCeiling"), bytes32("surplusAuctionAmountToSell"), uint(20000 * 10 ** 45), uint(10));
        assertEq(safeEngine.globalDebtCeiling(), 20000 * 10 ** 45);
        assertEq(accountingEngine.surplusAuctionAmountToSell(), 10);
    }

    // TODO
    function testRemoveAuthorizationAndModify() public {}

    function testRely() public {
        assertEq(oracleRelayer.authorizedAccounts(address(123)), 0);
        this.addAuthorization(address(pause), address(govActions), address(oracleRelayer), address(123));
        assertEq(oracleRelayer.authorizedAccounts(address(123)), 1);
    }

    function testUpdateRedemptionRate() public {
        hevm.warp(now + 1);
        assertTrue(oracleRelayer.redemptionPriceUpdateTime() < now);
        this.updateRedemptionRate(address(pause), address(govActions), address(oracleRelayer), bytes32("redemptionRate"), 10 ** 27 + 1);
        assertEq(oracleRelayer.redemptionPriceUpdateTime(), now);
    }

    function testUpdateAccumulatedRateAndModifyParameters() public {
        (uint stabilityFee,) = taxCollector.collateralTypes("ETH");
        assertEq(stabilityFee, 10 ** 27);
        this.modifyParameters(address(pause), address(govActions), address(taxCollector), bytes32("ETH"), bytes32("stabilityFee"), uint(2 * 10 ** 27));
        (stabilityFee,) = taxCollector.collateralTypes("ETH");
        assertEq(stabilityFee, 2 * 10 ** 27);
    }

    function testUpdateAccumulatedRateAndModifyParameters2() public {
        assertEq(coinSavingsAccount.savingsRate(), 10 ** 27);
        this.modifyParameters(address(pause), address(govActions), address(coinSavingsAccount), bytes32("savingsRate"), uint(2 * 10 ** 27));
        assertEq(coinSavingsAccount.savingsRate(), 2 * 10 ** 27);
    }

    function testSetAuthorityAndDelay() public {
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.delay(), 0);
        this.setAuthorityAndDelay(address(pause), address(govActions), address(123), 5);
        assertEq(address(pause.authority()), address(123));
        assertEq(pause.delay(), 5);
    }
}
