using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using HBMS_API.Models;


namespace HBMS_API.Controllers
{
    public class HBMSController : ApiController
    {
        static SqlConnection conn = new SqlConnection("Data Source=NDAMSSQL\\SQLILEARN;Initial Catalog=Training_13Aug19_Pune;User ID=sqluser;Password=sqluser");  //Connection String
        static SqlCommand cmd;     //Will be used to store and execute command
        static SqlDataReader dr;


        [HttpGet]
        public int UserAlreadyExist(string username, string email, string phoneno)
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
        public bool PostUser(User user) //Insert
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
                cmd.Parameters.AddWithValue("@password", user.PasswordHash);
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

        //login
        [HttpGet]
        public User Login(string loginid, string password)
        {
            User loggedin = new User();
            try
            {
                cmd = new SqlCommand("HBMS.VerifyLogin", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@loginid", loginid);
                cmd.Parameters.AddWithValue("@password", password);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (!reader.Read())
                    return null;
                loggedin.UserID = (int)reader[0];
                loggedin.UserName = (string)reader[1];
                loggedin.Email = (string)reader[2];
                loggedin.PhoneNo = (string)reader[3];
                loggedin.Name = (string)reader[4];
                loggedin.PasswordHash = null;
                loggedin.UserType = (string)reader[6];
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
            if (loggedin.UserName == null)
                return null;
            return loggedin;
        }

        [HttpPut]
        public bool ChangePassword(User user, string passwordnew)
        {
            bool changed = false;
            try
            {
                cmd = new SqlCommand("HBMS.ChangePassword", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@loginid", user.UserName);
                cmd.Parameters.AddWithValue("@password", user.PasswordHash);
                cmd.Parameters.AddWithValue("@passwordnew", passwordnew);
                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    changed = true;
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
            return changed;
        }

        [HttpPut]
        public bool ChangeDetails(User user)
        {
            bool changed = false;
            try
            {
                cmd = new SqlCommand("HBMS.ChangeDetails", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@username", user.UserName);
                cmd.Parameters.AddWithValue("@email", user.Email);
                cmd.Parameters.AddWithValue("@phoneno", user.PhoneNo);
                cmd.Parameters.AddWithValue("@name", user.Name);
                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    changed = true;
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
            return changed;
        }


        //CRUD Operations for Hotels

        [HttpPost]
        public bool PostHotel(Hotel hotel) //Add a New Hotel 
        {
            bool hotelAdded = false;

            try
            {
                cmd = new SqlCommand("HBMS.AddHotel", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@hotelname", hotel.HotelName);
                cmd.Parameters.AddWithValue("@location", hotel.Location);
                cmd.Parameters.AddWithValue("@hoteltype", hotel.HotelType);
                cmd.Parameters.AddWithValue("@rating", hotel.Rating);
                cmd.Parameters.AddWithValue("@wifi", hotel.WiFi);
                cmd.Parameters.AddWithValue("@geyser", hotel.Geyser);
                cmd.Parameters.AddWithValue("@startingat", hotel.StartingAt);
                cmd.Parameters.AddWithValue("@discount", hotel.Discount);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    hotelAdded = true;
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
            return hotelAdded;
        }

        [HttpGet]
        public List<Hotel> GetHotels() //List All Hotels
        {
            List<Hotel> hotelList = new List<Hotel>();

            try
            {
                cmd = new SqlCommand("HBMS.ShowHotels", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                DataTable hotelTable = new DataTable();

                hotelTable.Load(reader);

                for (int i = 0; i < hotelTable.Rows.Count; i++)
                {
                    Hotel hotel = new Hotel();

                    hotel.HotelID = (int)hotelTable.Rows[i][0];
                    hotel.HotelName = (string)hotelTable.Rows[i][1];
                    hotel.Location = (string)hotelTable.Rows[i][2];
                    hotel.HotelType = (string)hotelTable.Rows[i][3];
                    hotel.Rating = (double)hotelTable.Rows[i][4];
                    hotel.WiFi = (string)hotelTable.Rows[i][5];
                    hotel.Geyser = (string)hotelTable.Rows[i][6];
                    hotel.StartingAt = (double)hotelTable.Rows[i][7];
                    hotel.Discount = (double)hotelTable.Rows[i][8];

                    hotelList.Add(hotel);
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
            conn.Close();
            return hotelList;
        }

        [HttpGet]
        public Hotel GetHotelByID(int? id) //Search for a Hotel by ID
        {
            Hotel hotel = new Hotel();

            try
            {
                cmd = new SqlCommand("HBMS.SearchHotelByID", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@hotelid", id);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                DataTable hotelTable = new DataTable();

                hotelTable.Load(reader);

                for (int i = 0; i < hotelTable.Rows.Count; i++)
                {
                    

                    hotel.HotelID = (int)hotelTable.Rows[i][0];
                    hotel.HotelName = (string)hotelTable.Rows[i][1];
                    hotel.Location = (string)hotelTable.Rows[i][2];
                    hotel.HotelType = (string)hotelTable.Rows[i][3];
                    hotel.Rating = (double)hotelTable.Rows[i][4];
                    hotel.WiFi = (string)hotelTable.Rows[i][5];
                    hotel.Geyser = (string)hotelTable.Rows[i][6];
                    hotel.StartingAt = (double)hotelTable.Rows[i][7];
                    hotel.Discount = (double)hotelTable.Rows[i][8];

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

            return hotel;
        }

        [HttpGet]
        public List<Hotel> GetHotelsByName(string name) //Search for Hotels by Name
        {
            List<Hotel> hotelList = new List<Hotel>();

            try
            {
                cmd = new SqlCommand("HBMS.SearchHotelByName", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@hotelname", name);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                DataTable hotelTable = new DataTable();

                hotelTable.Load(reader);

                for (int i = 0; i < hotelTable.Rows.Count; i++)
                {

                    Hotel hotel = new Hotel();

                    hotel.HotelID = (int)hotelTable.Rows[i][0];
                    hotel.HotelName = (string)hotelTable.Rows[i][1];
                    hotel.Location = (string)hotelTable.Rows[i][2];
                    hotel.HotelType = (string)hotelTable.Rows[i][3];
                    hotel.Rating = (double)hotelTable.Rows[i][4];
                    hotel.WiFi = (string)hotelTable.Rows[i][5];
                    hotel.Geyser = (string)hotelTable.Rows[i][6];
                    hotel.StartingAt = (double)hotelTable.Rows[i][7];
                    hotel.Discount = (double)hotelTable.Rows[i][8];

                    hotelList.Add(hotel);
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

            return hotelList;
        }


        [HttpPut]
        public bool PutHotelByID(Hotel hotel ) //Modify Hotel by ID
        {
            bool hotelUpdated = false;
            try
            {
                cmd = new SqlCommand("HBMS.ModifyHotelByID", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@hotelid", hotel.HotelID);
                cmd.Parameters.AddWithValue("@hotelname", hotel.HotelName);
                cmd.Parameters.AddWithValue("@location", hotel.Location);
                cmd.Parameters.AddWithValue("@hoteltype", hotel.HotelType);
                cmd.Parameters.AddWithValue("@rating", hotel.Rating);
                cmd.Parameters.AddWithValue("@wifi", hotel.WiFi);
                cmd.Parameters.AddWithValue("@geyser", hotel.Geyser);
                cmd.Parameters.AddWithValue("@startingat", hotel.StartingAt);
                cmd.Parameters.AddWithValue("@discount", hotel.Discount);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    hotelUpdated = true;
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }
            return hotelUpdated;
        }

        [HttpPut]
        public bool PutHotelByName(Hotel hotel) //Modify Hotel by Name
        {
            bool hotelUpdated = false;
            try
            {
                cmd = new SqlCommand("HBMS.ModifyHotelByName", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                //cmd.Parameters.AddWithValue("@hotelid", hotel.HotelID);
                cmd.Parameters.AddWithValue("@hotelname", hotel.HotelName);
                cmd.Parameters.AddWithValue("@location", hotel.Location);
                cmd.Parameters.AddWithValue("@hoteltype", hotel.HotelType);
                cmd.Parameters.AddWithValue("@rating", hotel.Rating);
                cmd.Parameters.AddWithValue("@wifi", hotel.WiFi);
                cmd.Parameters.AddWithValue("@geyser", hotel.Geyser);
                cmd.Parameters.AddWithValue("@startingat", hotel.StartingAt);
                cmd.Parameters.AddWithValue("@discount", hotel.Discount);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    hotelUpdated = true;
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
            return hotelUpdated;
        }

        [HttpDelete]
        public bool DeleteHotelByID(int? id) //Delete a Hotel by ID
        {
            bool hotelDeleted = false;

            try
            {
                cmd = new SqlCommand("HBMS.DeleteHotelByID", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@hotelid", id);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    hotelDeleted = true;
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

            return hotelDeleted;
        }

        [HttpDelete]
        public bool DeleteHotelByName(string name) //Delete a Hotel by Name
        {
            bool hotelDeleted = false;

            try
            {
                cmd = new SqlCommand("HBMS.DeleteHotelByName", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@hotelname", name);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    hotelDeleted = true;
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

            return hotelDeleted;
        }

        //CRUD Operations for Room Details

        [HttpPost]
        public bool PostRoom(RoomDetail room) //Add a New Room 
        {
            bool roomAdded = false;

            try
            {
                cmd = new SqlCommand("HBMS.AddRooms", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@roomno", room.RoomNo);
                cmd.Parameters.AddWithValue("@hotelid", room.HotelID);
                cmd.Parameters.AddWithValue("@price", room.Price);
                cmd.Parameters.AddWithValue("@beds", room.Beds);
                cmd.Parameters.AddWithValue("@roomtype", room.RoomType);
                
                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    roomAdded = true;
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
            return roomAdded;
        }

        [HttpGet]
        public List<RoomDetail> GetRooms() //List All Rooms
        {
            List<RoomDetail> roomList = new List<RoomDetail>();

            try
            {
                cmd = new SqlCommand("HBMS.ShowRooms", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                DataTable roomTable = new DataTable();

                roomTable.Load(reader);

                for (int i = 0; i < roomTable.Rows.Count; i++)
                {
                    RoomDetail room = new RoomDetail();

                    room.RoomID = (int)roomTable.Rows[i][0];
                    room.RoomNo = (int)roomTable.Rows[i][1];
                    room.HotelID = (int)roomTable.Rows[i][2];
                    room.Price = (double)roomTable.Rows[i][3];
                    room.Beds = (string)roomTable.Rows[i][4];
                    room.RoomType = (string)roomTable.Rows[i][5];

                    roomList.Add(room);
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
            conn.Close();
            return roomList;
        }

        [HttpGet]
        public RoomDetail GetRoomByID(int? id) //Search for a Room by ID
        {
            RoomDetail room = new RoomDetail();

            try
            {
                cmd = new SqlCommand("HBMS.SearchRoomByID", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@roomid", id);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                DataTable roomTable = new DataTable();

                roomTable.Load(reader);

                for (int i = 0; i < roomTable.Rows.Count; i++)
                {


                    room.RoomID = (int)roomTable.Rows[i][0];
                    room.RoomNo = (int)roomTable.Rows[i][1];
                    room.HotelID = (int)roomTable.Rows[i][2];
                    room.Price = (double)roomTable.Rows[i][3];
                    room.Beds = (string)roomTable.Rows[i][4];
                    room.RoomType = (string)roomTable.Rows[i][5];
                    

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

            return room;
        }

        [HttpDelete]
        public bool DeleteRoomByID(int? id) //Delete a Room by ID
        {
            bool roomDeleted = false;

            try
            {
                cmd = new SqlCommand("HBMS.DeleteRoomByID", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@roomid", id);

                conn.Open();

                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    roomDeleted = true;
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

            return roomDeleted;
        }

        [HttpPut]
        public bool PutRoomByID(RoomDetail room) //Modify Room by ID
        {
            bool roomUpdated = false;
            try
            {
                cmd = new SqlCommand("HBMS.ModifyRoomByID", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@roomid", room.RoomID);
                cmd.Parameters.AddWithValue("@roomno", room.RoomNo);
                cmd.Parameters.AddWithValue("@hotelid", room.HotelID);
                cmd.Parameters.AddWithValue("@price", room.Price);
                cmd.Parameters.AddWithValue("@beds", room.Beds);
                cmd.Parameters.AddWithValue("@roomtype", room.RoomType);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    roomUpdated = true;
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
            return roomUpdated;
        }


        //CRUD operations for Booking Details

        [HttpPost]
        public bool PostBookRooms(BookingDetail booking,string roomtype,int hotelid,string beds) //Book a new Room
        {
            bool bookingAdded = false;

            try
            {
                cmd = new SqlCommand("HBMS.BookRooms", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@userid", booking.UserID);
                cmd.Parameters.AddWithValue("@guestname", booking.GuestName);
                cmd.Parameters.AddWithValue("@roomtype", roomtype);
                cmd.Parameters.AddWithValue("@hotelid", hotelid);
                cmd.Parameters.AddWithValue("@bookingfrom", booking.BookingFrom);
                cmd.Parameters.AddWithValue("@bookingto", booking.BookingTo);
                cmd.Parameters.AddWithValue("@beds", beds);
                cmd.Parameters.AddWithValue("@guestnum", booking.GuestNum);
                cmd.Parameters.AddWithValue("@breakfastincluded",booking.BreakfastIncluded);
                cmd.Parameters.AddWithValue("@totalamount",booking.TotalAmount);

                conn.Open();
                int result = cmd.ExecuteNonQuery();
                if (result > 0)
                {
                    bookingAdded = true;
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
            return bookingAdded;
        }

        [HttpGet]
        public List<BookingDetail> GetAllBookings() //list all Booking Details
        {
            List<BookingDetail> bookingList = new List<BookingDetail>();

            try
            {
                cmd = new SqlCommand("HBMS.ShowBookings", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                DataTable bookingTable = new DataTable();

                bookingTable.Load(reader);

                for (int i = 0; i < bookingTable.Rows.Count; i++)
                {
                    BookingDetail booking = new BookingDetail();

                    booking.BookingID = (int)bookingTable.Rows[i][0];
                    booking.UserID = (int)bookingTable.Rows[i][1];
                    booking.GuestName = (string)bookingTable.Rows[i][2];
                    booking.RoomID = (int)bookingTable.Rows[i][3];
                    booking.BookingFrom = (DateTime)bookingTable.Rows[i][4];
                    booking.BookingTo = (DateTime)bookingTable.Rows[i][5];
                    booking.GuestNum = (int)bookingTable.Rows[i][6];
                    booking.BreakfastIncluded = (string)bookingTable.Rows[i][7];
                    booking.TotalAmount = (double)bookingTable.Rows[i][8];
                    booking.BookingStatus = (string)bookingTable.Rows[i][9];

                    bookingList.Add(booking);
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
            return bookingList;
        }


    }
}
