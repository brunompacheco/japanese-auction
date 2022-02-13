// Agent sample_agent in project japanese_a

/* Initial beliefs and rules */

reserve_price(Price) :-
    .random(R) &
    Price = 100 + (100 * R)
    .

/* Initial goals */

!register.

/* Plans */

+!register
    <-  .wait(100);
        lookupArtifact("auction",ArtId);
        focus(ArtId);
        ?current_price(Price)[artifact_id(ArtId)];
        !maybe_join_auction(ArtId,Price);
        .

+!maybe_join_auction(ArtId,InitialPrice)
    :   reserve_price(ResPrice) &
        InitialPrice <= ResPrice
    <-  .print("I'm joining the auction");
        join[artifact_id(ArtId)];
        +joined(ArtId);
        .
+!maybe_join_auction(_,_)
    <-  .print("I'm not joining the auction");
        .

+current_price(Price)[artifact_id(ArtId)]
    :   joined(ArtId) &
        reserve_price(ResPrice) &
        Price > ResPrice
    <-  .print("price too high for me, I'm leaving the auction");
        leave[artifact_id(ArtId)];
        .

+winner(Winner)[artifact_id(ArtId)]
    :   joined(ArtId) &
        .my_name(Winner)
    <-  .print("I won the auction!");
        .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
