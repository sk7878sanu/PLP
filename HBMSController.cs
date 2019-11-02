using HBMS_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Mvc;

namespace HBMS_MVC.Controllers
{
    public class HBMSController : Controller
    {
        static SqlConnection conn = new SqlConnection("Data Source=NDAMSSQL\\SQLILEARN;Initial Catalog=Training_13Aug19_Pune;User ID=sqluser;Password=sqluser");  //Connection String
        static SqlCommand cmd;     //Will be used to store and execute command
        static SqlDataReader dr;
        UserAccount LoggedInUser=null;

        // GET: HBMS
        public ActionResult Home()
        {
            return View();
        }

        public ActionResult RegisterUser()
        {
            
            return View();
        }

        public ActionResult ChangePassword()
        {
            return View();
        }

        public ActionResult ChangeDetails()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RegisterUser([Bind(Include = "UserId,UserName,Email,PhoneNo,Name,Password,UserType")]UserAccount user,string Confirm_Password)
        {
            if (ModelState.IsValid)
            {
                int result = 0;
                using (var client = new HttpClient())
                {
                    client.BaseAddress = new Uri("http://localhost:63458/api/");
                    var responseTask = client.GetAsync($"HBMS/Get?username={user.UserName}&email={user.Email}&phoneno={user.PhoneNo}");
                    responseTask.Wait();

                    var res = responseTask.Result;
                    if (res.IsSuccessStatusCode)
                    {
                        var readTask = res.Content.ReadAsAsync<Int32>();
                        readTask.Wait();
                        result = readTask.Result;
                    }
                }

                if (user.Password != Confirm_Password)
                {
                    ModelState.AddModelError("Confirm_Password", "Does Not Match With Password");
                }
                else if (result == 0)
                {

                    using (var client = new HttpClient())
                    {
                        client.BaseAddress = new Uri("http://localhost:63458/api/");
                        var postTask = client.PostAsJsonAsync<UserAccount>("HBMS", user);
                        postTask.Wait();

                        var res = postTask.Result;
                        if (res.IsSuccessStatusCode)
                        {
                            var readTask = res.Content.ReadAsAsync<bool>();
                            readTask.Wait();
                            if (readTask.Result)
                            {
                                return RedirectToAction("Login", "HBMS");
                            }
                        }
                    }
                }
                if (result % 10 == 1)
                {
                    ModelState.AddModelError("UserName", "Entered UserName Not Available");
                }
                if ((result/10)%10==1)
                {
                    ModelState.AddModelError("Email", $"An account already exists with {user.Email}");
                }
                if (result / 100 == 1)
                {
                    ModelState.AddModelError("PhoneNo", $"An account already exists with {user.PhoneNo}");
                }
                
            }
            
            return View(user);
        }

        public ActionResult Login()
        {
            return View();
        }

        public ActionResult LoggedOut()
        {

            LoggedInUser = null;
            return View();
        }
    }
}