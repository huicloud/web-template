package cn.com.gw.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import cn.com.gw.util.ZLibUtils;

public class RdFileServlet extends HttpServlet {

	private static final long serialVersionUID = -2213292022751283677L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String address = request.getParameter("address");

		URL url = new URL(address);
		String content = new String(ZLibUtils.decompress(url.openStream()), "gbk");
		content = content.replaceAll("<body>", "").replaceAll("</body>", "");
		
		response.setContentType("text/plain;charset=UTF-8");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();
		
		out.print(content);
		out.flush();
	}


}
