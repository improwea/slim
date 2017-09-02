



<%
   
    // The following method invalidates the session when the user clicks logout button
    session.invalidate();
   
    response.sendRedirect("../login.jsp");
    
 %>