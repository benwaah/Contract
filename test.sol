contract owned
{
	address public owner;

	function owned()
	{
		owner = msg.sender;
	}

	modifier onlyOwner
	{
		if (msg.sender != owner)
			throw;
	}

	function transferOwnership(address newOwner) onlyOwner
	{
		owner = newOwner;
	}
}

contract MyToken is owned
{
	/* Public variables of the token */
	string public name;
	string public symbol;
	uint8 public decimals;

	/* This creates an array with all balances */
	mapping (address => uint256) public balanceOf;
	mapping (address => bool) public frozenAccount;
	mapping (address => bool) public approvedAccount;

	/* This generates a public event on the blockchain that will notify clients */
	event Transfer(address indexed from, address indexed to, uint256 value);
	event FrozenFunds(address target, bool frozen);
	event ApprovedFunds(address target, bool approve);

	/* Initializes contract with initial supply tokens to the creator of the contract */
	function MyToken(uint256 initialSupply, string tokenName,
					string tokenSymbol, uint8 tokenDecimals,
					address centralMinter)
	{
		if (centralMinter != 0)
			owner = msg.sender;

		// If supply not given generate one million
		if (initialToken == 0)
			initialToken = 1000000;
		// Give the creator initial tokens
		balanceOf[msg.sender] = initialToken;

		// Set the name for display purposes
		name = tokenName;
		// Set the symbol for display purposes
		symbol = tokenSymbol;
		// Amount of decimals for display purposes
		decimals = tokenDecimals;
	}

	/* Send coins */
	function transfer(address _to, uint256 _value)
	{
		/* Check if the sender has a frozen account */
		if (frozenAccount[msg.sender])
			throw;

		/* Check if the sender if approved for transfer */
		if (!approvedAccount[msg.sender])
			throw;

		/* Check if the sender has enough balance */
		if (balanceOf[msg.sender] < _value)
			throw;

		/* Check for overflows */
		if (balanceOf[_to] + _value < balanceOf[_to])
			throw;

		/* Add and substract new balances */
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;

		/* Notify anyone listening that this transfer took place */
		Transfer(msg.sender, _to, _value);
	}

	function mintToken(address _target, uint256 _mintedAmount) onlyOwner
	{
		balanceOf[_target] += _mintedAmount;
		Transfer(0, _target, _mintedAmount)
	}

	function freezeAccount(address _target, bool _freeze) onlyOwner
	{
		frozenAccount[_target] = _freeze;
		FrozenFunds(_target, _freeze);
	}

	function approveAccount(address _target, bool _approve) onlyOwner
	{
		approvedAccount[_target] = _approve;
		ApprovedFunds(_target, _approve);
	}
}
