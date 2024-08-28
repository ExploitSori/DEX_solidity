// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/console.sol";
contract Dex is ERC20{
	IERC20 token_a;
	IERC20 token_b;
	ERC20 lp;
	constructor(address _token_a, address _token_b) ERC20("DEX_Token", "DTK") {
		token_a = IERC20(_token_a);
		token_b = IERC20(_token_b);
	}
	function addLiquidity(uint256 a1, uint256 a2, uint256 a3) external returns(uint) {
		// a1 : a token amount
		// a2 : b token amount
		// a3 : 최소 기대 lp token
		uint mint_cnt;
		require(a1 > 0 && a2 > 0, "AddLiquidity invalid initialization check error - 1");
		require(a2 > 0, "AddLiquidity invalid initialization check error - 2" );
		require(a1 > 0, "AddLiquidity invalid initialization check error - 3");
		//transferFrom(address from, address to, uint256 value)
		uint a_cnt = token_a.allowance(msg.sender, address(this));
		uint b_cnt = token_b.allowance(msg.sender, address(this));
		if( a_cnt < a1 || b_cnt < a2){
			revert("ERC20: insufficient allowance");
		}	
		a_cnt = token_a.balanceOf(msg.sender);
		b_cnt = token_a.balanceOf(msg.sender);
		if( a_cnt < a1 || b_cnt < a2){
			revert("ERC20: transfer amount exceeds balance");
		}	
		uint totalSupply = totalSupply();
		if (totalSupply == 0) {
			mint_cnt = (a1 + a2) / 2;
		}
		else {
			if(a1 < a2){
				mint_cnt = a1;
			}
			else{
				mint_cnt = a2;
			}
		}	
		require(mint_cnt >= a3, "Insufficient LP tokens minted");
		token_a.transferFrom(msg.sender, address(this), a1);
		token_b.transferFrom(msg.sender, address(this), a2);
		_mint(msg.sender, mint_cnt);
		return mint_cnt;	
	}
	function removeLiquidity(uint a1, uint256 a2, uint256 a3) external returns(uint, uint){
		
		uint r1;
		uint r2;

		return (r1, r2);
	}
	function swap(uint a1, uint a2, uint a3) external returns(uint ret){
		uint ret;

		return ret;
	}
}
