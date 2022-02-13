// Agent sample_agent in project japanese_a

/* Initial beliefs and rules */

reserve_price("product_id",Price) :-
    .random(R) &
    Price = 100 + (100 * R)
    .

/* Initial goals */

!register.

/* Plans */

+!register
    <-  .df_register("buyer");
        .df_subscribe("seller");
        .

+auction(ProductID,ProductPrice)[source(Seller)]
    :   reserve_price(ProductID,MyPrice) &
        ProductPrice < MyPrice
    <-  .send(Seller,tell,join_auction(ProductID));
        .print("I am interested in ",ProductID," at price ",ProductPrice);
        .
+auction(ProductID,_)[source(Seller)]
    <-  .send(Seller,tell,ignore_auction(ProductID));
        .
