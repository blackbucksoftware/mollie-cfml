# mollie-cfml

**mollie-cfml** is a CFML library for interacting with the Mollie API v2.

## Installation
This wrapper can be installed as standalone library or as a ColdBox Module. Either approach requires a simple CommandBox command:

```
$ box install molliecfml
```

Alternatively the git repository can be cloned.

### Standalone Usage

Once the library has been installed, the core `mollie` component can be instantiated directly:

```cfc
mollie = new path.to.molliecfml.mollie(
    key = '',
    baseUrl = ''
);
```

### ColdBox Module

To use the library as a ColdBox Module, add the init arguments to the `moduleSettings` struct in `config/Coldbox.cfc`:

```cfc
moduleSettings = {
    molliecfml: {
        key: '',
        baseUrl: ''
    }
}
```

You can subsequently reference the library via the injection DSL: `mollie@molliecfml`:

```cfc
property name="mollie" inject="mollie@molliecfml";
```

## Getting Started

```
<!--- Create a payment and send the user to Mollie's checkout --->
<cfset paymentLink = mollie.createPayment(
        currency = "EUR",
        value = "20.00",
        description = "My Item",
        redirectUrl = "https://my.site.com/thankyou",
        webhookUrl = "https://my.site.com/mollie",
        method = "sofort,giropay,creditcard,applepay,ideal,eps",
        metadata = [ { "orderid": "ABC001" } ]
    ) />

<cflocation url=paymentLink.data._links.checkout.href addtoken=false />    
```

## Methods available

**mollie-cfml** covers currently these methods of the Mollie API v2:


| Mollie API    | methods available           |   |
|---------------|-----------------------------|---|
| [Payments](https://docs.mollie.com/reference/v2/payments-api/overview)      | createPayment()             |   |
|               | getPayment()                |   |
|               | updatePayment()             |   |
|               | cancelPayment()             |   |
|               | listPayments()              |   |
| [Methods](https://docs.mollie.com/reference/v2/methods-api/overview)       | listMethods()               |   |
|               | listAllMethods()            |   |
|               | getMethod()                 |   |
| [Refunds](https://docs.mollie.com/reference/v2/refunds-api/overview)       | createRefund()              |   |
|               | getRefund()                 |   |
|               | cancelRefund()              |   |
|               | listRefunds()               |   |
|               | listAllRefunds()            |   |
| [Chargebacks](https://docs.mollie.com/reference/v2/chargebacks-api/overview)   | getChargeback()             |   |
|               | listChargebacks()           |   |
|               | listAllChargebacks()        |   |
| [Customers](https://docs.mollie.com/reference/v2/customers-api/overview)     | createCustomer()            |   |
|               | getCustomer()               |   |
|               | updateCustomer()            |   |
|               | deleteCustomer()            |   |
|               | listCustomers()             |   |
|               | createCustomerPayment()     |   |
|               | listCustomerPayments()      |   |
| [Mandates](https://docs.mollie.com/reference/v2/mandates-api/overview)      | createMandate()             |   |
|               | getMandate()                |   |
|               | revokeMandate()             |   |
|               | listMandates()              |   |
| [Subscriptions](https://docs.mollie.com/reference/v2/subscriptions-api/overview) | createSubscription()        |   |
|               | getSubscription()           |   |
|               | updateSubscription()        |   |
|               | cancelSubscription()        |   |
|               | listCustomerSubscriptions() |   |
|               | listAllSubscriptions()      |   |
|               | listSubscriptionPayments()  |   |
| [Settlements](https://docs.mollie.com/reference/v2/settlements-api/overview)   | getSettlement()             |   |

