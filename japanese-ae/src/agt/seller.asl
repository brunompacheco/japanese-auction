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
    <-  ?reserve_price(Price)
        makeArtifact("auction","tools.JapaneseAuction",[Price],ArtId);
        focus(ArtId);
        .print("Created auction");
        .wait(1000);
        start_auction[artifact_id(ArtId)];
        .

+winner(Winner)[artifact_id(AId)]
    :   Winner \== no_one
    <-  ?current_price(Price)[artifact_id(AId)];
        .print("Agent ",Winner," won my auction for the price of ",Price);
        .

+current_price(Price)[artifact_id(AId)]
    <-  .print("Price now at ", Price);
        .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
