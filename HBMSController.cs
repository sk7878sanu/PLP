using HBMS_WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace HBMS_WebAPI.Controllers
{
    public class HBMSController : ApiController
    {
        static SqlConnection conn = new SqlConnection("Data Source=NDAMSSQL\\SQLILEARN;Initial Catalog=Training_13Aug19_Pune;User ID=sqluser;Password=sqluser");  //Connection String
        static SqlCommand cmd;     //Will be used to store and execute command
        static SqlDataReader dr;

        
        [HttpGet]
        public int UserAlreadyExist(string username,string email,string phoneno)
        {
            int result = 0;
            try
            {
                cmd = new SqlCommand("HBMS.UserAlreadyExist", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@username", username);
                cmd.Parameters.AddWithValue("@email", email);
                cmd.Parameters.AddWithValue("@phoneno", phoneno);
                conn.Open();
                result = Convert.ToInt32(cmd.ExecuteScalar());
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }

            return result;
        }

        [HttpPost]
        public bool PostUser(UserAccount user) //Insert
        {
            bool registered = false;
            try
            {
                cmd = new SqlCommand("HBMS.RegisterUser", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@username", user.UserName);
                cmd.Parameters.AddWithValue("@email", user.Email);
                cmd.Parameters.AddWithValue("@phoneno", user.PhoneNo);
                cmd.Parameters.AddWithValue("@name", user.Name);
                cmd.Parameters.AddWithValue("@password", user.Password);
                cmd.Parameters.AddWithValue("@usertype", user.UserType);
                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    registered = true;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
            return registered;
        }
    }
}
