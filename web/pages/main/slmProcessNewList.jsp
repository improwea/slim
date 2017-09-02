<%@ page import = "java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import = "org.apache.commons.fileupload.*" %>
<%@ page import = "org.apache.commons.fileupload.disk.*" %>
<%@ page import = "org.apache.commons.fileupload.servlet.*" %>
<%@ page import = "org.apache.commons.io.output.*" %>

<%@ page import ="org.apache.poi.ss.usermodel.Workbook" %>
<%@ page import ="org.apache.poi.ss.usermodel.Sheet" %>
<%@ page import ="org.apache.poi.ss.usermodel.Row" %>
<%@ page import ="org.apache.poi.ss.usermodel.Cell" %>
<%@ page import ="org.apache.poi.ss.usermodel.CreationHelper" %>
<%@ page import ="org.apache.poi.ss.usermodel.Comment" %>
<%@ page import ="org.apache.poi.ss.usermodel.ClientAnchor" %>
<%@ page import ="org.apache.poi.ss.usermodel.Drawing" %>
<%@ page import ="org.apache.poi.ss.usermodel.RichTextString" %>
<%@ page import ="org.apache.poi.ss.usermodel.CellStyle" %>
<%@ page import ="org.apache.poi.ss.usermodel.IndexedColors" %>
<%@ page import ="org.apache.poi.xssf.usermodel.XSSFWorkbook" %>

<%@ page import ="java.io.InputStream" %>
<%@ page import ="java.io.FileInputStream" %>
<%@ page import ="java.io.FileOutputStream" %>
<%@ page import ="java.io.IOException" %>
<%@ page import ="java.util.Map" %>
<%@ page import ="java.util.HashMap" %>

<%!
    
    /**
     * This method reads the excel sheet data - pushed to GIT
     *
     * @param args holds the following inputs
     *                          0 - file path
     *                          1 - sheet name
     *
     * @throws Exception if the operation fails.
     *
     * @return Map holds sheet data in the following pattern
     *            - Row data map holds all rows data with key as Row number and value as Column Map
     *            - Column Map holds 1 row data with key as Cell index and value as cell data
     */
    
    // this method gets the data from the Excel file
    public static Map getSheetData (String[] args) throws Exception
    {
        Map mSheetData = new HashMap<String, Map> ();
        if (args == null || args.length < 2) {
            throw new Exception("Illegal Argument Exception: Excel with data file path and sheet name should be sent as input to program");
        }
        String sFilePath = args[0];
        String sSheetName = args[1];
        try {
            // read excel file
            System.out.println ("Here "+sFilePath);
            InputStream inputStream = new FileInputStream(sFilePath);
            Workbook wb = new XSSFWorkbook(inputStream);
            Sheet sheet = wb.getSheet(sSheetName);
            if (sheet == null) {
                throw new Exception("Sheet name specified:\""+sSheetName+"\" doesn't exist in configurable file");
            }
            Map mRowData;
            // loops through each row in the sheet
            for (Row row : sheet) {
                mRowData = new HashMap<String, String> ();
                // loops through each cell in the row
                for (Cell cell : row) {
                    // capture row data in the map
                    mRowData.put(""+cell.getColumnIndex(), ""+getCellValue(cell));
                }
                // capture sheet data in the map
                mSheetData.put(""+row.getRowNum(), mRowData);
            }
        }
        catch (IOException e) {
            throw new Exception("Configurable file missing \n"+e.getMessage());
        }
        catch (Exception e) {
            throw new Exception("Exception while reading data from Excel Sheet: "+e.getMessage());
        }
        return mSheetData;
    }

    /**
     * Method to Get Value of a Cell
     *
     * @param cell - EXCEL CELL Object
     * @return a String - Contents of CELL
     * @throws Exception if operation fails
     */
    public static String getCellValue(Cell cell) 
    {
        String sCellData = "";
        double dCellData;
        switch (cell.getCellType()) 
        {
            case Cell.CELL_TYPE_BOOLEAN:
                sCellData = String.valueOf(cell.getBooleanCellValue());
                break;
            case Cell.CELL_TYPE_NUMERIC:
                dCellData = (double)cell.getNumericCellValue(); 
                sCellData = String.valueOf(dCellData).replaceFirst("\\.0+$", "");
                break;
            case Cell.CELL_TYPE_STRING:
                sCellData = String.valueOf(cell.getStringCellValue());
                break;
            case Cell.CELL_TYPE_FORMULA:
                sCellData = String.valueOf(cell.getRichStringCellValue());
                break;
            default:
                sCellData = String.valueOf(cell.getRichStringCellValue());
                break;
        }
        sCellData = sCellData.trim();
        if (sCellData==null || "NULL".equalsIgnoreCase(sCellData) || "null".equalsIgnoreCase(sCellData) || "".equalsIgnoreCase(sCellData))
        {
            sCellData = "-";
        }
        return sCellData.trim();
    }


%>



<%
   File file ;
   int maxFileSize = 5000 * 1024;
   int maxMemSize = 5000 * 1024;
   Map mSheetData = new HashMap<String, Map> ();
   
   ServletContext context = pageContext.getServletContext();
   
   //String filePath = context.getInitParameter("file-upload");
   
   System.out.println (context.getRealPath ("/"));
   
   String filePath = "/Users/nagarajanr/Downloads/temp/";
   
   // Verify the content type
   String contentType = request.getContentType();
   
   if ((contentType.indexOf("multipart/form-data") >= 0)) {
      DiskFileItemFactory factory = new DiskFileItemFactory();
      // maximum size that will be stored in memory
      factory.setSizeThreshold(maxMemSize);
      
      // Location to save data that is larger than maxMemSize.
      factory.setRepository(new File(filePath));

      // Create a new file upload handler
      ServletFileUpload upload = new ServletFileUpload(factory);
      
      // maximum file size to be uploaded.
      upload.setSizeMax( maxFileSize );
      
      try { 
         // Parse the request to get file items.
         List fileItems = upload.parseRequest(request);

         // Process the uploaded file items
         Iterator i = fileItems.iterator();

         out.println("<html>");
         out.println("<head>");
         out.println("<title>JSP File upload</title>");  
         out.println("</head>");
         out.println("<body>");
         
         while ( i.hasNext () ) {
            FileItem fi = (FileItem)i.next();
            if ( !fi.isFormField () ) {
                System.out.println ("Inside while");
               // Get the uploaded file parameters
               String fieldName = fi.getFieldName();
               String fileName = fi.getName();
               boolean isInMemory = fi.isInMemory();
               long sizeInBytes = fi.getSize();
            System.out.println ("Inside while "+sizeInBytes);
               // Write the file
               if( fileName.lastIndexOf("\\") >= 0 ) {
                  file = new File( filePath + 
                  fileName.substring( fileName.lastIndexOf("\\"))) ;
               } else {
                  file = new File( filePath + 
                  fileName.substring(fileName.lastIndexOf("\\")+1)) ;
               }
               System.out.println ("Inside while "+file);
               fi.write( file ) ;
             
               
               String[] args = {filePath+fileName, "Sample Database"};
               
               System.out.println ("filePath "+filePath);
               System.out.println ("fileName "+fileName); 
               
               mSheetData = getSheetData (args);
               
            }
         }
         //out.println("</body>");
         //out.println("</html>");
      } catch(Exception ex) {
         System.out.println("error "+ex);
      }
   } else {
      out.println("<html>");
      out.println("<head>");
      out.println("<title>Servlet upload</title>");  
      out.println("</head>");
      out.println("<body>");
      out.println("<p>No file uploaded</p>"); 
      out.println("</body>");
      out.println("</html>");
   }
 
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>SLIM: Subscribers List Manager</title>

    <!-- Bootstrap Core CSS -->
    <link href="../../vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="../../vendor/metisMenu/metisMenu.min.css" rel="stylesheet">

    <!-- DataTables CSS -->
    <link href="../../vendor/datatables-plugins/dataTables.bootstrap.css" rel="stylesheet">

    <!-- DataTables Responsive CSS -->
    <link href="../../vendor/datatables-responsive/dataTables.responsive.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="../../dist/css/sb-admin-2.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="../../vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head>

<body>

    <div id="wrapper">

        <!-- Navigation -->
        <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
            <div class="navbar-header">
                <a class="navbar-brand" href="index.html">SLIM: Subscribers List Manager</a>
            </div>
        </nav>

        <div id="wrapper">
            <div class="row">
                <div class="col-lg-12">
                    <h2 class="page-header">&nbsp;&nbsp;Review excel data before import:</h2>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <!--<div class="panel-heading">
                            DataTables Advanced Tables
                        </div>-->
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <table width="100%" class="table table-bordered table-hover" cellspacing="0" id="dataTables">
                                <thead>
                                    <tr>
                                        
                                        <%
                                             Map mHeadingRow= (HashMap) mSheetData.get("0"); 
                                             
                                             //SortedSet<Integer> keys = new TreeSet<Integer>(mHeadingRow.keySet());
                                             
                                             for (int i=0;i<mHeadingRow.size();i++) {
                                                 System.out.println (" > "+mHeadingRow.get(""+i));
                                        %>
                                                    <th><%=mHeadingRow.get(""+i)%></th>
                                        <%
                                            }
                                         %>
                                        
                                    </tr>
                                </thead>

                            </table>
                            <!-- /.table-responsive -->
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->

            <!-- /.row -->


            <!-- /.row -->
        </div>
        <!-- /#page-wrapper -->

    </div>
    <!-- /#wrapper -->

    <!-- jQuery -->
    <script src="../../vendor/jquery/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="../../vendor/bootstrap/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="../../vendor/metisMenu/metisMenu.min.js"></script>

    <!-- DataTables JavaScript -->
    <script src="../../vendor/datatables/js/jquery.dataTables.min.js"></script>
    <script src="../../vendor/datatables-plugins/dataTables.bootstrap.min.js"></script>
    <script src="../../vendor/datatables-responsive/dataTables.responsive.js"></script>

    <!-- Custom Theme JavaScript -->
    <script src="../../dist/js/sb-admin-2.js"></script>

    <!-- Page-Level Demo Scripts - Tables - Use for reference -->
    <script>
    $(document).ready(function() {
        var table = $('#dataTables').DataTable({
                            responsive: true
                        });
         
                                    <%
                                        for (int i=1;i<mSheetData.size();i++) {
                                            Map mContentRow= (HashMap) mSheetData.get(""+i);
                                    %>
                                            var rowData = new Array();
                                            
                                            <%
                                                 for (int j=0;j<mContentRow.size();j++) {
                                            %>                                
                                                    rowData.push("<%=mContentRow.get(""+j)%>"); 
                                            <%
                                                }
                                            %>
                                                table.row.add(rowData).draw();
                                        <%
                                        }
                                        %>         

         
     
        
        // var rowData = [,counter +'.2', counter +'.3', counter +'.4', counter +'.5', counter +'.1', counter +'.2', counter +'.3', counter +'.4', counter +'.5', counter +'.1',counter +'.2',counter +'.3',counter +'.4', counter +'.5',counter +'.1',counter +'.2',counter +'.3',counter +'.4']; 
         
         

        
    });
    
    

    
    </script>

</body>

</html>
