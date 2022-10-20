const Coupon = artifacts.require('Coupon');

module.exports = function(deployer){
  deployer.deploy(Coupon, 'NAME_TEST', 'SYMBOL_TEST');
}