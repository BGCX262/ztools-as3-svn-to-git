package zTools.json
{
	/**
	 * JSON格式的编码和解码工具类
	 * 
	 * @author Zivn
	 */
	public class JSON
	{
		/**
		 * 将源数据编码为 JSON 格式字符串
		 *
		 * @param o 源数据
		 */
		public static function encode(o:Object):String
		{	
			return new JSONEncoder(o).getString();
		}
		
		/**
		 * 将JSON 格式字符串解码为对象
		 * 
		 * @param s JSON 格式字符串
		 * @param strict 是否严格遵守JSON标准
		 */
		public static function decode(s:String, strict:Boolean = true):*
		{	
			return new JSONDecoder(s, strict).getValue();	
		}	
	}
}