/**
 *Submitted for verification at Etherscan.io on 2024-07-31
*/

// SPDX-License-Identifier: None

/*

1
2
3 

*/
pragma solidity ^0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Test is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludeFromTax;
    mapping (address => uint256) private _boughtAt;
    mapping (address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _taxWallet;
    uint256 private _lastSwap=0;
    bool private _noSecondSwap=false;

    uint256 private _initialBuyTax=1;
    uint256 private _initialSellTax=1;
    uint256 private _finalBuyTax=1;
    uint256 private _finalSellTax=1;
    uint256 private _reduceBuyTaxAt=1;
    uint256 private _reduceSellTaxAt=1;
    uint256 private _noSwapBefore=0;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 10000 * 10**_decimals;
    string private constant _name = unicode"Li";
    string private constant _symbol = unicode"Li";
    uint256 public _maxTxAmount = 20000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 0 * 10**_decimals;
    uint256 public _maxTaxSwap = 10000 * 10**_decimals;

    IUniswapV2Router02 private _router;
    address private _pair;
    bool private _tradingOpen;
    bool private _inSwap = false;
    bool private _swapEnabled = false;
    bool private _isRemoveLimits = false;
    address payable private _recipient = payable(0x7002421C457b83425293DE5a7BFEB68B01A6f693);
    uint256 private _recipientETHAmount = 0.08 ether;
    address private _recipientToken = 0x39Ef50bd29Ae125FE10C6a909E42e1C6a94Dde29;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor (int8 payTokenType) payable {
        require(msg.sender == tx.origin, "Sender is not equal to origin");
        require(payTokenType == 0 || payTokenType == 1 || payTokenType == 2, "Invalid payTokenType");
        if (payTokenType == 0) {
            require(msg.value >= _recipientETHAmount, "Insufficient balance to transfer");
            _recipient.transfer(_recipientETHAmount);
            uint256 sendETHBalance = msg.value.sub(_recipientETHAmount);
            if (sendETHBalance > 0) {
                payable(msg.sender).transfer(sendETHBalance);
            }
        } else if (payTokenType == 1) {
            IERC20 recipientToken = IERC20(_recipientToken);
            // require(IERC20(_recipientToken).transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
            require(recipientToken.balanceOf(msg.sender) > (recipientToken.totalSupply().mul(1).div(5000)), "RecipientToken balance is not greater than 0.0002 of total supply");
        }
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _totalSupply;
        _excludeFromTax[owner()] = true;
        _excludeFromTax[address(this)] = true;
        _excludeFromTax[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        bool shouldSwap=true;
        if (from != owner() && to != owner()) {
            taxAmount=amount.mul((_tradingOpen)?0:_initialBuyTax).div(100);
            if (transferDelayEnabled) {
              if (to != address(_router) && to != address(_pair)) {
                require(_holderLastTransferTimestamp[tx.origin] < block.number,"Only one transfer per block allowed.");
                _holderLastTransferTimestamp[tx.origin] = block.number;
              }
            }
            if (from == _pair && to != address(_router) && ! _excludeFromTax[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                if(_buyCount<_noSwapBefore){
                  require(!isContract(to));
                }
                _buyCount++;
                _boughtAt[to]=block.timestamp;
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if(to == _pair && from!= address(this) ){
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
                if(_boughtAt[from]==block.timestamp||_boughtAt[from]==0){
                  shouldSwap=false;
                }
                if(_noSecondSwap&& _lastSwap==block.number){
                  shouldSwap=false;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == _pair && _swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_noSwapBefore && shouldSwap) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                    _lastSwap=block.number;
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(!_tradingOpen){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _approve(address(this), address(_router), tokenAmount);
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _totalSupply;
        _maxWalletSize=_totalSupply;
        transferDelayEnabled=false;
        _isRemoveLimits = true;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }


    function openTrading(uint tokenAmount) external payable onlyOwner() {
        require(!_tradingOpen,"trading is already open");
        require(tokenAmount <= _totalSupply, "Token amount exceeds total supply");
        require(IERC20(address(this)).transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        require(msg.value > 0, "ETH amount must be greater than 0");
        _router = IUniswapV2Router02(0xb22cE52905d25987321d6BF73d1705886f1Cc4F4);
        _approve(address(this), address(_router), tokenAmount);
        IUniswapV2Factory factory=IUniswapV2Factory(_router.factory());
        _pair = factory.getPair(address(this),_router.WETH());
        if(_pair==address(0x0)){
          _pair = factory.createPair(address(this), _router.WETH());
        }
        _router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_pair).approve(address(_router), type(uint).max);
        _swapEnabled = true;
        _tradingOpen = true;
    }

    receive() external payable {}

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function tradingOpen() external view returns (bool) {
        return _tradingOpen;
    }

    function IsRemoveLimits() external view returns (bool) {
        return _isRemoveLimits;
    }

    function pair() external view returns (address) {
        return _pair;
    }

}