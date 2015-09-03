package receive;

import java.util.ArrayList;

import models.Party;
import util.ApiController;

/**
 * Created by John on 9/2/2015.
 */
public class ApiPartyListReader implements PartyListLoadable {
    private ApiPartyListReader mInstance;
    ApiController mApiController;

    protected ApiPartyListReader(){
        //defeat instantiation
    }

    public ApiPartyListReader getInstance(){
        if (mInstance == null){
            mInstance = new ApiPartyListReader();
            mApiController = ApiController.getInstance();
        }
        return mInstance;
    }

    public ArrayList<Party> getPartyList(){
        //TODO connect this
        return null;
    }
}
