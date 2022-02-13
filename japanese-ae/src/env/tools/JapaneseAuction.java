package tools;

import jason.asSyntax.Atom;
import java.util.Arrays;
import cartago.*;

public class JapaneseAuction extends Artifact {
    final static long ROUND_TIME = 1000;

    String current_winner = "no_one";
    String[] buyers = new String[0];

    @OPERATION public void init(int price)  {
        // observable properties
        defineObsProperty("winner",             new Atom(current_winner)); // Atom is a Jason type
        defineObsProperty("state",              0);  // initialized -> running -> finished
        defineObsProperty("current_price",      price);
    }

    @OPERATION public void start_auction()  {
        if (getObsProperty("state").intValue() >= 1)
            failed("The auction is already running!");

        getObsProperty("state").updateValue(1);

        if (buyers.length > 1) {
            execInternalOp("run");
        } else {
             execInternalOp("declare_winner");
        }
    }

    @INTERNAL_OPERATION void run() {
        while (getObsProperty("state").intValue() == 1) {
            await_time(ROUND_TIME);

            if (buyers.length > 1) {
                getObsProperty("current_price").updateValue(
                    getObsProperty("current_price").intValue() + 10
                );
            } else {
                getObsProperty("state").updateValue(2);
                execInternalOp("declare_winner");
            }
        }
    }

    @INTERNAL_OPERATION void declare_winner() {
        String winner = buyers[0];

        getObsProperty("winner").updateValue(new Atom(winner));
    }

    @OPERATION public void join()  {
        if (getObsProperty("state").intValue() > 0)
            failed("You cannot join this auction anymore");

        String new_buyer = getCurrentOpAgentId().getAgentName();

        // update list of buyers enrolled
        String[] new_buyers = new String[buyers.length + 1];

        for (int i = 0; i < buyers.length; i++) {
            new_buyers[i] = buyers[i];
        }
        new_buyers[buyers.length] = new_buyer;

        buyers = new_buyers;
    }

    @OPERATION public void leave() {
        if (getObsProperty("state").intValue() > 1)
            failed("The auction is already over");

        String quitter = getCurrentOpAgentId().getAgentName();

        String[] new_buyers = new String[buyers.length - 1];

        int j = 0;
        for (int i = 0; i < buyers.length; i++) {
            if (buyers[i] != quitter) {
                new_buyers[j] = buyers[i];
                j++;
            }
        }

        buyers = new_buyers;
    }
}
