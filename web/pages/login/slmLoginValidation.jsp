<%@ page language="java" 
    contentType="text/html; 
    charset=windows-1256"
     pageEncoding="windows-1256" 
     import="com.mongodb.BasicDBObject"
     import="com.mongodb.DB"
     import="com.mongodb.DBCollection"
     import="com.mongodb.DBCursor"
     import="com.mongodb.MongoClient"
     import="java.net.UnknownHostException"
	 import="com.sun.org.apache.bcel.internal.generic.NEW"
	 import="com.mongodb.DBObject"
	 import="com.mongodb.Mongo"
      %> 

<%

	System.out.println ("From Login Validtion");
	
	
	String strUserNameEntered = (String) request.getParameter ("email");
	String strPasswordEntered = (String) request.getParameter ("password");	
%>


<%
        int iErrorCode = 0;
        
        Mongo mg = new Mongo();
        DB db = mg.getDB("slim");
        DBCollection collection = db.getCollection("USER_MASTER");

        BasicDBObject searchQuery = new BasicDBObject();
        searchQuery.put("user_id", strUserNameEntered);

        DBCursor cursor = collection.find(searchQuery);

        System.out.println (cursor.hasNext());
        
        if (!cursor.hasNext()) {
            iErrorCode = 1;
        } else {
                String strPasswordFromDb = "";
                try 
                {
                    while(cursor.hasNext()) 
                    {
                        DBObject document = cursor.next();
                        System.out.println ("Password "+document.get("password"));
                        strPasswordFromDb = (String) document.get("password");
                        break;
                    }
                }
                 finally 
                 {
                    cursor.close();
                        mg.close();
                 }
                
                
                if (strPasswordFromDb!=null && strPasswordFromDb.equals(strPasswordEntered)) {
                    iErrorCode = -1;
                } else {
                    iErrorCode = 2;
                }
        }
        
        if (iErrorCode==-1) {
            
            session.setAttribute ("LOGGEDIN", "1");

            %>
                <script language="JavaScript">
                     document.location.href = "../main/slmHomePage.jsp";
                </script>
            <%            
        } else {
            %>
                <script language="JavaScript">
                     document.location.href = "../login.jsp?error=<%=iErrorCode%>";
                </script>
            <%
        }


 %>



		



