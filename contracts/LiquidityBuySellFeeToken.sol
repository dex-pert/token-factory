// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 *  ____            ____           _   
 * |  _ \  _____  _|  _ \ ___ _ __| |_ 
 * | | | |/ _ \ \/ / |_) / _ \ '__| __|
 * | |_| |  __/>  <|  __/  __/ |  | |_ 
 * |____/ \___/_/\_\_|   \___|_|   \__|
 *
 * This smart contract was created effortlessly using the DexPert Token Creator.
 * 
 * 🌐 Website: https://www.dexpert.io/
 * 🐦 Twitter: https://x.com/DexpertOfficial
 * 💬 Telegram: https://t.me/DexpertCommunity
 * 
 * 🚀 Unleash the power of decentralized finances and tokenization with DexPert Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!
 */
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { IUniswapV2Router02 } from "./interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "./interfaces/IUniswapV2Factory.sol";

enum TokenType {
    Standard,
    Liquidity,
    LiquidityFee,
    LiquidityBuySellFee,
    Burn,
    Baby,
    StandardAntiBot,
    LiquidityAntiBot,
    LiquidityFeeAntiBot,
    LiquidityBuySellFeeAntiBot,
    BurnAntiBot,
    BabyAntiBot
}

contract LiquidityBuySellFeeToken is IERC20, Initializable, OwnableUpgradeable {
    using Address for address;
    using SafeERC20 for IERC20;

    uint256 public constant VERSION = 1;
    uint256 public constant MAX_FEE = 10 ** 4 / 5;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // Transfer Fee
    uint256 public _taxFee;
    uint256 private _previousTaxFee;

    uint256 public _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public _marketingFee;
    uint256 private _previousMarketingFee;

    // Sell Fee
    uint256 private _sellTaxFee;
    uint256 private _sellLiquidityFee;
    uint256 private _sellMarketingFee;

    // Buy Fee
    uint256 private _buyTaxFee;
    uint256 private _buyLiquidityFee;
    uint256 private _buyMarketingFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public _marketingAddress;
    address public _marketingToken;

    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;

    uint256 private numTokensSellToAddToLiquidity;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyAmountUpdated(uint256 amount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address owner_,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address[3] memory addrs, // router, marketing wallet, marketing token
        uint16[3] memory feeSettings, // tax, liquidity, marketing
        uint16[3] memory buyFeeSettings, // buyTax, buyLiquidity, buyMarketing
        uint16[3] memory sellFeeSettings // sellTax, sellLiquidity, sellMarketing
    ) public initializer {
        // Set fees
        _taxFee = feeSettings[0];
        _previousTaxFee = _taxFee;

        _liquidityFee = feeSettings[1];
        _previousLiquidityFee = _liquidityFee;

        _marketingFee = feeSettings[2];
        _previousMarketingFee = _marketingFee;
        require(
            _taxFee + _liquidityFee + _marketingFee <= MAX_FEE,
            "fee is over 20%"
        );
        require(addrs[1] != address(0), "marketing wallet is zero");
        _marketingAddress = addrs[1];
        _marketingToken = addrs[2];

        // Set buy fees
        _buyTaxFee = buyFeeSettings[0];
        _buyLiquidityFee = buyFeeSettings[1];
        _buyMarketingFee = buyFeeSettings[2];
        require(
            _buyTaxFee + _buyLiquidityFee + _buyMarketingFee <= MAX_FEE,
            "buy fee is over 20%"
        );

        // Set sell fees
        _sellTaxFee = sellFeeSettings[0];
        _sellLiquidityFee = sellFeeSettings[1];
        _sellMarketingFee = sellFeeSettings[2];
        require(
            _sellTaxFee + _sellLiquidityFee + _sellMarketingFee <= MAX_FEE,
            "sell fee is over 20%"
        );

        _name = name_;
        _symbol = symbol_;
        _decimals = 9;

        _tTotal = totalSupply_;
        _rTotal = (MAX - (MAX % _tTotal));

        numTokensSellToAddToLiquidity = totalSupply_ / (10 ** 3); // 0.1%
        swapAndLiquifyEnabled = true;

        // Set the owner to the factory initializer caller
        __Ownable_init(msg.sender);
        transferOwnership(owner_);

        _rOwned[owner()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addrs[0]);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(
        uint256 rAmount
    ) public view returns (uint256) {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

/*
    function excludeFromReward(address account) public onlyOwner {
        require(_excluded.length <= 1000, "Cannot exclude more accounts");
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
*/

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

/**
    function updateFees(
        uint256 taxFeeBps,
        uint256 liquidityFeeBps,
        uint256 marketingFeeBps
    ) external onlyOwner {
        _taxFee = taxFeeBps;
        _liquidityFee = liquidityFeeBps;
        _marketingFee = marketingFeeBps;
        require(
            _taxFee + _liquidityFee + _marketingFee <= MAX_FEE,
            "fee is over 20%"
        );
    }

    function updateBuyFees(
        uint256 taxFeeBps,
        uint256 liquidityFeeBps,
        uint256 marketingFeeBps
    ) external onlyOwner {
        _buyTaxFee = taxFeeBps;
        _buyLiquidityFee = liquidityFeeBps;
        _buyMarketingFee = marketingFeeBps;
        require(
            _buyTaxFee + _buyLiquidityFee + _buyMarketingFee <= MAX_FEE,
            "buy fee is over 20%"
        );
    }

    function updateSellFees(
        uint256 taxFeeBps,
        uint256 liquidityFeeBps,
        uint256 marketingFeeBps
    ) external onlyOwner {
        _sellTaxFee = taxFeeBps;
        _sellLiquidityFee = liquidityFeeBps;
        _sellMarketingFee = marketingFeeBps;
        require(
            _sellTaxFee + _sellLiquidityFee + _sellMarketingFee <= MAX_FEE,
            "sell fee is over 20%"
        );
    }
*/

    function setSwapBackSettings(uint256 _amount) external onlyOwner {
        require(
            _amount >= (totalSupply() * 5) / (10 ** 4),
            "Swapback amount should be at least 0.05% of total supply"
        );
        require(
            _amount < (totalSupply() * 5) / 100,
            "Swapback amount should be less than 5% of the total supply"
        );
        numTokensSellToAddToLiquidity = _amount;
        emit SwapAndLiquifyAmountUpdated(_amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(
        uint256 tAmount
    )
        private
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tMarketing,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity,
            tMarketing
        );
    }

    function _getTValues(
        uint256 tAmount
    ) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tTransferAmount = ((tAmount - tFee) - tLiquidity) - tMarketing;
        return (tTransferAmount, tFee, tLiquidity, tMarketing);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tMarketing,
        uint256 currentRate
    ) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rTransferAmount = ((rAmount - rFee) - rLiquidity) - rMarketing;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }

    function _takeMarketingFee(uint256 tMarketing) private {
        address receiver = _marketingAddress;

        if (_marketingToken != address(0)) receiver = address(this);

        if (tMarketing > 0) {
            uint256 currentRate = _getRate();
            uint256 rMarketing = tMarketing * currentRate;
            _rOwned[receiver] = _rOwned[receiver] + rMarketing;
            if (_isExcluded[receiver])
                _tOwned[receiver] = _tOwned[receiver] + tMarketing;
            emit Transfer(_msgSender(), receiver, tMarketing);
        }
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxFee) / (10 ** 4);
    }

    function calculateLiquidityFee(
        uint256 _amount
    ) private view returns (uint256) {
        return (_amount * _liquidityFee) / (10 ** 4);
    }

    function calculateMarketingFee(
        uint256 _amount
    ) private view returns (uint256) {
        if (_marketingAddress == address(0)) return 0;
        return (_amount * _marketingFee) / (10 ** 4);
    }

    function removeAllFee() private {
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousMarketingFee = _marketingFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(amount > 0, "transfer amount is zero");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;

        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            from != address(uniswapV2Router) &&
            swapAndLiquifyEnabled
        ) {
            inSwapAndLiquify = true;

            uint256 _totalFees = _liquidityFee +
                _sellLiquidityFee +
                _buyLiquidityFee +
                _marketingFee +
                _sellMarketingFee +
                _buyMarketingFee;

            contractTokenBalance = numTokensSellToAddToLiquidity;

            if (
                _marketingFee > 0 ||
                _sellMarketingFee > 0 ||
                _buyMarketingFee > 0
            ) {
                uint256 marketingTokens = (contractTokenBalance *
                    (_marketingFee + _sellMarketingFee + _buyMarketingFee)) /
                    _totalFees;
                sendMarketingFee(_marketingToken, marketingTokens);
            }

            if (
                _liquidityFee > 0 ||
                _sellLiquidityFee > 0 ||
                _buyLiquidityFee > 0
            ) {
                uint256 swapTokens = (contractTokenBalance *
                    (_liquidityFee + _sellLiquidityFee + _buyLiquidityFee)) /
                    _totalFees;
                swapAndLiquify(swapTokens);
            }

            inSwapAndLiquify = false;
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = !inSwapAndLiquify;

        //don't take fee on liquidity removals
        if (from == uniswapV2Pair && to == address(uniswapV2Router))
            takeFee = false;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (owner() == from || owner() == to || _marketingAddress == from || _marketingAddress == to || address(this) == from || address(this) == to) {
            takeFee = false;
        }

        //indicates if buy or sell fee is applied from transfer
        bool isBuySellFee = false;

        if (takeFee) {
            _previousTaxFee = _taxFee;
            _previousLiquidityFee = _liquidityFee;
            _previousMarketingFee = _marketingFee;
            // on sell
            if (uniswapV2Pair == to) {
                _taxFee = _sellTaxFee;
                _liquidityFee = _sellLiquidityFee;
                _marketingFee = _sellMarketingFee;
                isBuySellFee = true;
            }
            // on buy
            else if (uniswapV2Pair == from) {
                _taxFee = _buyTaxFee;
                _liquidityFee = _buyLiquidityFee;
                _marketingFee = _buyMarketingFee;
                isBuySellFee = true;
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        // if buy or sell fee is setted restore to normal fees
        if (isBuySellFee) restoreAllFee();
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(
        address tokenAddress,
        uint256 tokenAmount
    ) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = tokenAddress;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendMarketingFee(
        address tokenAddress,
        uint256 tokenAmount
    ) private {
        // Send native token
        if (tokenAddress == uniswapV2Router.WETH()) {
            uint256 initialBalance = address(this).balance;

            swapTokensForEth(tokenAmount);

            tokenAmount = address(this).balance - initialBalance;

            payable(_marketingAddress).transfer(tokenAmount);
            // Send custom token
        } else if (tokenAddress != address(0)) {
            uint256 initialTokenBalance = IERC20(tokenAddress).balanceOf(
                address(this)
            );

            swapTokensForTokens(tokenAddress, tokenAmount);

            tokenAmount =
                (IERC20(tokenAddress).balanceOf(address(this))) -
                initialTokenBalance;

            IERC20(tokenAddress).safeTransfer(_marketingAddress, tokenAmount);
            // Send this token
        } else {
            _transfer(address(this), _marketingAddress, tokenAmount);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{ value: ethAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}
