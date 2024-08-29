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
		b_cnt = token_b.balanceOf(msg.sender);
		if( a_cnt < a1 || b_cnt < a2){
			revert("ERC20: transfer amount exceeds balance");
		}	
		uint totalSupply = totalSupply();
		if (totalSupply == 0) {
			uint cont_a_cnt = token_a.balanceOf(address(this));
			uint cont_b_cnt = token_b.balanceOf(address(this));
			if(a1 + cont_a_cnt < a2 + cont_b_cnt){
				mint_cnt = a2 + cont_b_cnt;
			}
			else{
				mint_cnt = a1 + cont_a_cnt;
			}
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
	function removeLiquidity(uint burn_cnt, uint256 a_min, uint256 b_min) external returns(uint, uint){
		uint r1;
		uint r2;
		uint dtk = balanceOf(msg.sender);
		require(dtk >= burn_cnt, "Insufficient LP tokens to burn");
		uint pool_a = token_a.balanceOf(address(this));
		uint pool_b = token_b.balanceOf(address(this));
		uint totalSupply = totalSupply();

		r1 = (burn_cnt * pool_a) / totalSupply;
		r2 = (burn_cnt * pool_b) / totalSupply;
		console.log(r1);
		console.log(r2);
		require( a_min <= r1,"RemoveLiquidity minimum return error");
		require( b_min <= r2,"RemoveLiquidity minimum return error");
		_burn(msg.sender, burn_cnt);
		token_a.transfer(msg.sender, r1);
		token_b.transfer(msg.sender, r2);

		return (r1, r2);
	}
	function swap(uint a_token_amount, uint b_token_amount, uint min_swap) external returns(uint ret){
		uint ret;
		uint pool_a = token_a.balanceOf(address(this));
		uint pool_b = token_b.balanceOf(address(this));
		uint fee = 999;
		bool target = a_token_amount > b_token_amount ? true:false;
		uint256 swap_amount; 
		if(target){
			require(b_token_amount == 0);
			swap_amount = pool_b - ((pool_a * pool_b) / (pool_a + a_token_amount));
			swap_amount = swap_amount * fee / 1000;
			require(swap_amount >= min_swap, "Output amount is less than the minimum required");
			token_a.transferFrom(msg.sender,address(this), a_token_amount);
			token_b.transfer(msg.sender, swap_amount);
		}
		else{
			require(a_token_amount == 0);
			swap_amount = pool_a - ((pool_a * pool_b) / (pool_b + b_token_amount));
			swap_amount = swap_amount * fee / 1000;
			require(swap_amount >= min_swap, "Output amount is less than the minimum required");
			token_b.transferFrom(msg.sender,address(this), b_token_amount);
			token_a.transfer(msg.sender, swap_amount);
		}

		return swap_amount;
	}
}
