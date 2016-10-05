#r "Newtonsoft.Json"

using System;
using System.Configuration;
using System.Data.SqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;

public static void Run(string myEventHubMessage, TraceWriter log)
{
    //log.Info($"incoming raw message: {myEventHubMessage}");
    
    JArray messageArray = JArray.Parse(myEventHubMessage);

    try
    {
        foreach(var message in messageArray)
        {
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = new SqlConnection(ConfigurationManager.ConnectionStrings["SqlServerConnectionString"].ConnectionString);
                cmd.Connection.Open();
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.CommandText = "Persist";
                cmd.Parameters.Add(new SqlParameter("@message", message.ToString(Formatting.None)));
                cmd.ExecuteNonQuery();
            }               
        }
    }
    catch (Exception ex)
    {
        // This can fail as a result of a cmd problem.
        log.Info($"Event Hub trigger function failed with {ex.Message}.");
    }
}
