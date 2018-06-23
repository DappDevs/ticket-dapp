/**
 * Copied from: https://gomakethings.com/how-to-get-the-value-of-a-querystring-with-native-javascript/
 * Get the value of a querystring
 * @param  {String} field The field to get the value of
 * @param  {String} url   The URL to get the value from (optional)
 * @return {String}       The field value
 */
var getQueryString = function ( field, url ) {
    var href = url ? url : window.location.href;
    var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
    var string = reg.exec(href);
    return string ? string[1] : null;
};

var eventAddress = getQueryString('event');
if (eventAddress)
{
    //var Web3 = require('web3');
    //var web3 = new Web3();
    alert(web3);

    var eventName = document.getElementById('eventName');
}
