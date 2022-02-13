// Agent sample_agent in project japanese_a

/* Initial beliefs and rules */

id("product_id").

reserve_price(100).

auction_round_deadline(1000).

all_buyers_entered(ProductID,NBuyers) :-
    .count(join_auction(ProductID),NJoined) &
    .count(ignore_auction(ProductID),NIgnored) &
    NBuyers = NJoined + NIgnored
    .

/* Initial goals */

!start.

/* Plans */

+!start
    <-  .df_register("seller");
        .print("Started auction");
        .wait(1000);
        !start_auction
        .

+!start_auction
    :   id(ProductID) &
        reserve_price(Price)
    <-  .df_search("buyer",Buyers);
        +curr_price(Price);
        !auction_round(ProductID,Buyers);
        .

+!auction_round(ProductID,Buyers)
    :   auction_round_deadline(Deadline) &
        curr_price(Price)
    <-  .print("New round for product ",ProductID," at price ",Price);
        .send(Buyers,tell,auction(ProductID,Price));
        .wait(Deadline);
        .findall(Agent,join_auction(ProductID)[source(Agent)],InterestedBuyers);
		for ( .member(Agent,InterestedBuyers) ) {
			-join_auction(ProductID)[source(Agent)];
		}
        !check_winner(ProductID,InterestedBuyers);
        .

+!check_winner(ProductID,InterestedBuyers)
    :   .length(InterestedBuyers) = 1 &
        curr_price(Price)
    <-  for ( .member(Winner,InterestedBuyers) ) {
            .print(Winner," won product ",ProductID," at price ",Price);
            .send(Winner,tell,winner(Winner,Price));
        }
        -curr_price(Price);
        .
+!check_winner(ProductID,InterestedBuyers)
    :   curr_price(Price)
    <-  -curr_price(Price);
        +curr_price(Price * 1.1);
        !auction_round(ProductID,InterestedBuyers);
        .stopmas;
        .
+!check_winner(ProductID,[])
    <-  .print("NO BUYERS ANYMORE");
        .stopmas;
        .
