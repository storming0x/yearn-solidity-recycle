/* SPDX-License-Identifier: MIT */
pragma solidity ^0.6.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// TODO: not sure this is needed, may remove later
// interface USDTLike {
//     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
//     function approve(address spender, uint256 amount) external returns (bool);
// }

interface yVault {
    function deposit(uint256 _amount) external;
}

interface yCurveFi {
    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount) external;
}

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Recycle {
    using SafeERC20 for IERC20;

    address public constant yDEPOSIT = address(0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3);
    address public constant yCURVE = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    address public constant yUSD = address(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);

    address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address public constant TUSD = address(0x0000000000085d4780B73119b644AE5ecd22b376);

    event Recycled(
        address indexed user, 
        uint256 sentDAI,
        uint256 sentUSDC,
        uint256 sentUSDT,
        uint256 sentTUSD,
        uint256 sentYCRV,
        uint256 receivedYUSD
    );

    constructor () public {
        approveToken();
    }

    function approveToken() public {
        IERC20(DAI).safeApprove(yDEPOSIT, uint(-1));
        IERC20(USDC).safeApprove(yDEPOSIT, uint(-1));
        IERC20(USDT).safeApprove(yDEPOSIT, uint(-1));
        IERC20(TUSD).safeApprove(yDEPOSIT, uint(-1));

        IERC20(yCURVE).safeApprove(yUSD, uint(-1));
    }

    function _recycleExactAmounts(
        address _sender, 
        uint256 _dai, 
        uint256 _usdc, 
        uint256 _usdt,
        uint256 _tusd,
        uint256 _ycrv
    ) internal {
        if (_dai > 0) {
            IERC20(DAI).safeTransferFrom(_sender, address(this), _dai);
        }
        if (_usdc > 0) {
            IERC20(USDC).safeTransferFrom(_sender, address(this), _usdc);
        }
        if (_usdt > 0) {
            IERC20(USDT).safeTransferFrom(_sender, address(this), _usdt);
        }
        if (_tusd > 0) {
            IERC20(TUSD).safeTransferFrom(_sender, address(this), _tusd);
        }
        if (_ycrv > 0) {
            IERC20(yCURVE).safeTransferFrom(_sender, address(this), _ycrv);
        }

        if (_dai + _usdc + _usdt + _tusd > 0) {
            uint256[4] memory depositAmounts = [_dai, _usdc, _usdt, _tusd];
            yCurveFi(yDEPOSIT).add_liquidity(depositAmounts, 0);
        }

        // NOTE: should we check balance here before depositing to check against 
        // initial balance and compare after side effect
        // in case somebody accidentaly sends yUSD to this contract?
        uint256 ycrvBalance  = IERC20(yCURVE).balanceOf(address(this));
        if  (ycrvBalance > 0) {
            yVault(yUSD).deposit(ycrvBalance);
        }
        // NOTE: see comment above
        uint256 _yusd  = IERC20(yUSD).balanceOf(address(this));
        IERC20(yUSD).safeTransfer(_sender, _yusd);

        require(IERC20(yCURVE).balanceOf(address(this)) == 0, "!LEFTOVER_BALANCE");

        emit Recycled(_sender, _dai, _usdc, _usdt, _tusd, _ycrv, _yusd);
    }

    function recycle() external {
        uint256 _dai = Math.min(IERC20(DAI).balanceOf(msg.sender), IERC20(DAI).allowance(msg.sender, address(this)));
        uint256 _usdc = Math.min(IERC20(USDC).balanceOf(msg.sender), IERC20(USDC).allowance(msg.sender, address(this)));
        uint256 _usdt = Math.min(IERC20(USDT).balanceOf(msg.sender), IERC20(USDT).allowance(msg.sender, address(this)));
        uint256 _tusd = Math.min(IERC20(TUSD).balanceOf(msg.sender), IERC20(TUSD).allowance(msg.sender, address(this)));
        uint256 _ycrv = Math.min(IERC20(yCURVE).balanceOf(msg.sender), IERC20(yCURVE).allowance(msg.sender, address(this)));

        _recycleExactAmounts(msg.sender, _dai, _usdc, _usdt, _tusd, _ycrv);
    }

    function recycleExact(
        uint256 _dai, 
        uint256 _usdc, 
        uint256 _usdt,
        uint256 _tusd,
        uint256 _ycrv
    ) external {
        _recycleExactAmounts(msg.sender, _dai, _usdc, _usdt, _tusd, _ycrv);
    }
    
}
