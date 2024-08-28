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
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {IRouter02} from "./interfaces/IRouter02.sol";
import {SafeMath} from "./lib/SafeMath.sol";

enum TokenType {
    Standard01,
    Standard02
}

struct TokenMetadata {
    string name;
    string symbol;
    uint8 decimals;
    uint256 totalSupply;
    string logoLink;
    string twitterLink;
    string telegramLink;
    string discordLink;
    string websiteLink;
    uint256 maxTxAmount;
    uint256 maxWalletSize;
    uint256 taxSwapThreshold;
    uint256 maxTaxSwap;
    uint256 initialBuyTax;
    uint256 initialSellTax;
    uint256 finalBuyTax;
    uint256 finalSellTax;
    uint256 reduceBuyTaxAt;
    uint256 reduceSellTaxAt;
    uint256 noSwapBefore;
    uint256 buyCount;
    string description;
}

contract StandardToken02 is IERC20, Initializable, OwnableUpgradeable {
    using SafeMath for uint256;
    uint256 public constant VERSION = 1;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 public _maxTxAmount;
    uint256 public _maxWalletSize;
    uint256 public _taxSwapThreshold;
    uint256 public _maxTaxSwap;

    string public description;
    string public logoLink;
    string public twitterLink;
    string public telegramLink;
    string public discordLink;
    string public websiteLink;
    bool public tradingOpen;
    IRouter02 private _router;
    address private pair;

    mapping(address => bool) private _excludeFromTax;
    mapping(address => uint256) private _boughtAt;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _taxWallet;
    uint256 private _lastSwap = 0;
    bool private _noSecondSwap = false;

    uint256 private _initialBuyTax;
    uint256 private _initialSellTax;
    uint256 private _finalBuyTax;
    uint256 private _finalSellTax;
    uint256 private _reduceBuyTaxAt;
    uint256 private _reduceSellTaxAt;
    uint256 private _noSwapBefore;
    uint256 private _buyCount;
    bool private _tradingOpen;
    bool private _inSwap = false;
    bool private _swapEnabled = false;
    bool private isRemoveLimits = false;

    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address owner_,
        TokenMetadata memory tokenMetadata
    ) public initializer {
        _name = tokenMetadata.name;
        _symbol = tokenMetadata.symbol;
        _decimals = tokenMetadata.decimals;
        logoLink = tokenMetadata.logoLink;
        twitterLink = tokenMetadata.twitterLink;
        telegramLink = tokenMetadata.telegramLink;
        discordLink = tokenMetadata.discordLink;
        websiteLink = tokenMetadata.websiteLink;
        description = tokenMetadata.description;
        _maxTxAmount = tokenMetadata.maxTxAmount * 10 ** _decimals;
        _maxWalletSize = tokenMetadata.maxWalletSize * 10 ** _decimals;
        _taxSwapThreshold = tokenMetadata.taxSwapThreshold * 10 ** _decimals;
        _maxTaxSwap = tokenMetadata.maxTaxSwap * 10 ** _decimals;
        _initialBuyTax = tokenMetadata.initialBuyTax;
        _initialSellTax = tokenMetadata.initialSellTax;
        _finalBuyTax = tokenMetadata.finalBuyTax;
        _finalSellTax = tokenMetadata.finalSellTax;
        _reduceBuyTaxAt = tokenMetadata.reduceBuyTaxAt;
        _reduceSellTaxAt = tokenMetadata.reduceSellTaxAt;
        _noSwapBefore = tokenMetadata.noSwapBefore;
        _buyCount = tokenMetadata.buyCount;
        __Ownable_init(msg.sender);
        transferOwnership(owner_);
        _mint(owner(), tokenMetadata.totalSupply * 10 ** _decimals);

        _taxWallet = payable(owner_);
        _excludeFromTax[owner()] = true;
        _excludeFromTax[address(this)] = true;
        _excludeFromTax[_taxWallet] = true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
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

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        bool shouldSwap = true;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_tradingOpen) ? 0 : _initialBuyTax).div(
                100
            );
            if (transferDelayEnabled) {
                if (to != address(_router) && to != address(pair)) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "Only one transfer per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }
            if (
                from == pair && to != address(_router) && !_excludeFromTax[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                if (_buyCount < _noSwapBefore) {
                    require(!isContract(to));
                }
                _buyCount++;
                _boughtAt[to] = block.timestamp;
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);
            }

            if (to == pair && from != address(this)) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
                if (
                    _boughtAt[from] == block.timestamp || _boughtAt[from] == 0
                ) {
                    shouldSwap = false;
                }
                if (_noSecondSwap && _lastSwap == block.number) {
                    shouldSwap = false;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !_inSwap &&
                to == pair &&
                _swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _noSwapBefore &&
                shouldSwap
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                    _lastSwap = block.number;
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount==0) {return;}
        if (!_tradingOpen) {return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WBTC();
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
        _maxWalletSize = _totalSupply;
        transferDelayEnabled = false;
        isRemoveLimits = true;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading(
        address router,
        uint tokenAmount
    ) external payable onlyOwner {
        require(!tradingOpen, "trading is already open");
        require(
            tokenAmount <= _totalSupply,
            "Token amount exceeds total supply"
        );
        require(
            IERC20(address(this)).transferFrom(
                msg.sender,
                address(this),
                tokenAmount
            ),
            "Token transfer failed"
        );
        require(msg.value > 0, "ETH amount must be greater than 0");
        _router = IRouter02(router);
        _approve(address(this), router, tokenAmount);
        IFactory factory = IFactory(_router.factory());
        pair = factory.getPair(address(this), _router.WBTC());
        if (pair == address(0x0)) {
            pair = factory.createPair(address(this), _router.WBTC());
        }
        _router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(pair).approve(router, type(uint).max);
        tradingOpen = true;
    }

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
}
