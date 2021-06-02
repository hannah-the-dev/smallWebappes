<%@ page language="java" import="java.sql.*, java.net.URL"
	contentType="text/html; charset=UTF-8"%>

<html>
<head>
	<style>
	table, tr, th, td {
		border: 1px solid black;
		border-collapse: collapse;
	}
	ul {
		list-style: none;
		margin: 10px 0 0 100px;

	}
	li {
		float: left;
		margin: 10 10 10 10;
	}
	</style>
</head>
<body>
	<% 	request.setCharacterEncoding("UTF-8");
		
		Class.forName("com.mysql.cj.jdbc.Driver"); 
		Connection conn = DriverManager.getConnection("jdbc:mysql://192.168.23.17:3306/kopoctc", "root", "kopoctc");
		Statement stmt = conn.createStatement();
		double lat = 37.3860521;  
		double lng = 127.1214038; 
		int pageNum = 1;  		//default value
		int maxPage = 0;
		int lastRow = 0;
		int listSize = 10;		// number of list of pages
		boolean prev = false;
		boolean next = true;
		int startPage = 1;
		int endPage = 10;
		int perPage = 1;
		int inPage = 0;
	
		String _from = request.getParameter("from");
		_from = ((_from == null) || (_from.equals("0"))) ? "1" : _from;
		String _cnt = request.getParameter("cnt");
		_cnt = (_cnt == null) || (_cnt.equals("0")) ? "10" : _cnt ;
		
		ResultSet rcnt = stmt.executeQuery("select count(*) from freeWifi");
		while(rcnt.next()) {
			lastRow = rcnt.getInt(1);
		};
		
		try { //abs value to parse negative int
			perPage = Math.abs(Integer.parseInt(_cnt));		
		} catch (Exception e){
			perPage = 1;
		}
		
		try {	//abs value to parse negative int
			inPage = Math.abs(Integer.parseInt(_from)) > lastRow ? 
			lastRow : Math.abs(Integer.parseInt(_from));
			
		} catch (Exception e){
			inPage = 1;
		}
		if (perPage == 1) {
			maxPage = lastRow;
		} else {	
			maxPage = (lastRow / (perPage-1)) - (lastRow / (perPage * 1.0 - 1)) == 0 ? 
				(lastRow / (perPage))  : 
				(lastRow / (perPage)) + lastRow % perPage / perPage;   
		}
	
		startPage = ((inPage / (perPage * listSize))) < 1 ? 1 : 
			 ((inPage / (perPage * listSize))) * listSize +1;


		if ((perPage * (maxPage+1)) - (inPage) < perPage) {
			startPage = maxPage;
		}

			
		endPage = (startPage + listSize) -1 < maxPage ? 
			(startPage + listSize) -1 : maxPage ; 
		int new_pageRow = 1;
		int new_startRow = 1;
		
		prev = startPage == 1? false : true;
		next = endPage == maxPage ? false : true;
		
		String queryTxt;
		CallableStatement cs = null;
		
		cs = conn.prepareCall("{call GET_WIFI_FROM_TO(?, ?, ?, ?)}");
		cs.setDouble(1, lat);
		cs.setDouble(2, lng);
		cs.setInt(3, inPage-1);
		cs.setInt(4, perPage);	
		ResultSet rset = cs.executeQuery();		
		
	%>
	<h1>무료 와이파이</h1>
	<p>총 레코드: <%= lastRow %><br>
	 총 페이지: <%= maxPage %></p>
	<%= startPage %>
	<%= endPage %>
	<table>
		<tr>
			<th>번호</th>
			<th>도로명주소</th>
			<th>위도</th>
			<th>경도</th>
			<th>거리</th>
		</tr>
		<% while(rset.next()) { %>
		<tr>
			<td> <%= rset.getInt(1) %> </td>
			<td> <%= rset.getString(2) %> </td>
			<td> <%= rset.getString(3) %> </td>
			<td> <%= rset.getString(4) %> </td>
			<td> <%= rset.getString(5) %> </td>
		</tr>
		<% } %>
	</table>	
	<ul>
		<% if(prev) { %>
		<li> <a href="wifi.jsp?from=<%= new_pageRow = (((startPage-1)*perPage +1) - perPage * listSize) < 1 ? 1 : (((startPage-1)*perPage +1) - perPage * listSize) %>&cnt=<%= perPage %>"> &#12298; </a> </li>
		<% }
		for (int i = startPage; i < endPage+1; i++) { %>
		<li> <a href="wifi.jsp?from=<%= (i-1) * perPage +1 %>&cnt=<%= perPage %>"><%= i %></a> </li> 
		<% } 
		 if (next) {%>
		<li> <a href="wifi.jsp?from=<%= new_startRow = (((startPage-1)*perPage +1) + perPage * listSize) > lastRow ? lastRow : (((startPage-1)*perPage +1) + perPage * listSize) %>&cnt=<%= perPage %>"> &#12299; </a> </li>
		 <% }%>
	</ul>	
	</table>

</body>
</html>