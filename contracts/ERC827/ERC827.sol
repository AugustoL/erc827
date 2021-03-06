/* solium-disable security/no-low-level-calls */

pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./ERC827Proxy.sol";


/**
 * @title ERC827, an extension of ERC20 token standard
 *
 * @dev Implementation the ERC827, following the ERC20 standard with extra
 * methods to transfer value, data and execute calls inside transfers and
 * approvals. Uses OpenZeppelin ERC20.
 */
contract ERC827 is ERC20 {

  ERC827Proxy public proxy;

  /**
   * @dev Constructor
   */
  constructor() public {
    proxy = new ERC827Proxy();
  }

  /**
   * @dev Addition to ERC20 token methods. It allows to
   * approve the transfer of value and execute a call with the sent data.
   * Beware that changing an allowance with this method brings the risk that
   * someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race condition
   * is to first reduce the spender's allowance to 0 and set the desired value
   * afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address that will spend the funds.
   * @param _value The amount of tokens to be spent.
   * @param _data ABI-encoded contract call to call `_spender` address.
   * @return true if the call function was executed successfully
   */
  function approveAndCall(address _spender, uint256 _value, bytes memory _data)
    public payable returns (bool)
  {
    super.approve(_spender, _value);
    _call(_spender, _data);
    return true;
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens to a specified
   * address and execute a call with the sent data on the same transaction
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   * @param _data ABI-encoded contract call to call `_to` address.
   * @return true if the call function was executed successfully
   */

  function transferAndCall(address _to, uint256 _value, bytes memory _data)
    public payable returns (bool)
  {
    super.transfer(_to, _value);
    _call(_to, _data);
    return true;
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens from one address to
   * another and make a contract call on the same transaction
   * @param _from The address which you want to send tokens from
   * @param _to The address which you want to transfer to
   * @param _value The amout of tokens to be transferred
   * @param _data ABI-encoded contract call to call `_to` address.
   * @return true if the call function was executed successfully
   */
  function transferFromAndCall(
    address _from, address _to, uint256 _value, bytes memory _data
  )
    public payable returns (bool)
  {
    super.transferFrom(_from, _to, _value);
    _call(_to, _data);
    return true;
  }

  /**
   * @dev Addition to ERC20 methods. Increase the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait
   * until the first transaction is mined)
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function increaseAllowanceAndCall(
    address _spender, uint _addedValue, bytes memory _data
  )
    public payable returns (bool)
  {
    super.increaseAllowance(_spender, _addedValue);
    _call(_spender, _data);
    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait
   * until the first transaction is mined)
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function decreaseAllowanceAndCall(
    address _spender, uint _subtractedValue, bytes memory _data
  )
    public payable returns (bool)
  {
    super.decreaseAllowance(_spender, _subtractedValue);
    _call(_spender, _data);
    return true;
  }

  /**
   * @dev Call a external contract
   * @param _to The address of the contract to call
   * @param _data ABI-encoded contract call to call `_to` address.
   */
  function _call(address _to, bytes memory _data) internal {

    // solium-disable-next-line security/no-call-value, no-unused-vars
    (bool success, bytes memory data) = address(proxy).call.value(msg.value)(
      abi.encodeWithSelector(proxy.callContractFunctionSignature(), _to, _data)
    );

    require(success, "Call to external contract failed");
  }

}
