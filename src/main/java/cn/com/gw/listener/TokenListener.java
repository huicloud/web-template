package cn.com.gw.listener;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.apache.http.HttpEntity;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.util.EntityUtils;

import cn.com.gw.util.HttpClientUtil;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;

public class TokenListener implements HttpSessionListener {

	private final static String host = "v2.yundzh.com";
	private final static String appid = "eeea786772d911e5ab560242ac110006";
	private final static String secret_key = "3PoNZFjSKARo";
	
	@Override
	public void sessionCreated(HttpSessionEvent se) {
		//每次创建session，都重新申请token 
		CloseableHttpClient httpClient = HttpClientUtil.createSSLClientDefault();
		
		try {  
            HttpGet httpget = new HttpGet("https://"+host+"/token/access?appid="+appid+"&secret_key="+secret_key);
            CloseableHttpResponse response = httpClient.execute(httpget);  
            try {  
                HttpEntity entity = response.getEntity(); 
                 
                if (entity != null) {  
                    String responseContent = EntityUtils.toString(entity);
                    // 解析云平台返回数据
                    // "{'Qid':'','Err':0,'Counter':1,'Data':{'Id':44,'RepDataToken':[{'result':0,'token':'dc4deb92ef284804a44d232df0244a9d','create_time':1444972107,'duration':86400,'appid':'eeea786772d911e5ab560242ac110006','uid':''}]}}";
                    Map<String, Object> map = JSON.parseObject(responseContent, new TypeReference<Map<String, Object>>() {});
            		map = JSON.parseObject(map.get("Data").toString(), new TypeReference<Map<String, Object>>() {});
            		
            		String repDataToken = map.get("RepDataToken").toString();
            		List<Map<String, Object>> repDatas = JSON.parseObject(repDataToken, new TypeReference<List<Map<String,Object>>>(){});
            		
            		String token = repDatas.get(0).get("token").toString();
            		se.getSession().setAttribute("yundzhToken", token);
                    
                }  
            } finally {  
                response.close();  
            }  
        } catch (ClientProtocolException e) {  
            e.printStackTrace();  
        } catch (ParseException e) {  
            e.printStackTrace();  
        } catch (IOException e) {  
            e.printStackTrace();  
        } finally {  
            // 关闭连接,释放资源    
            try {  
            	httpClient.close();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
        }  
		
	}

	@Override
	public void sessionDestroyed(HttpSessionEvent se) {
		
	}

}
