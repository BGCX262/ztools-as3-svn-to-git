package zTools.utils
{		
	/**
	 * 字符串工具类
	 *  
	 * @author Zivn
	 */	
	public class StringUtil
	{
		private static function isWhitespace(str:String):Boolean
		{
			switch (str)
			{
				case " ":
				case "\t":
				case "\r":
				case "\n":
				case "\f":
				case "\v":
					return true;					
				default:
					return false;
			}
		}
		
		/**
		 * 去掉源字符串两端的空白
		 * 
		 * @param str 源字符串
		 */		
		public static function trim(str:String):String
		{
			if (str == null)
			{
				return '';
			}
			
			var startIndex:int = 0;
			var endIndex:int = str.length - 1;
			
			while (isWhitespace(str.charAt(startIndex)))
			{
				++startIndex;
			}
			
			while (isWhitespace(str.charAt(endIndex)))
			{
				--endIndex;
			}				
			
			if (endIndex >= startIndex)
			{
				return str.slice(startIndex, endIndex + 1);
			}
			else
			{
				return "";
			}
		}
		
		/**
		 *  以第二个参数开始的所有参数替换源字符串中的{n}标记，生成新的字符串
		 * 
		 * @param str 源字符串
		 * @param rest 标记替换的值
		 * 
		 * @example
		 *  var str:String = "here is some info '{0}' and {1}, '{0}' is a number.";
		 *  trace(StringUtil.substitute(str, 15.4, true));
		 * 
		 *  // this will output the following string:
		 *  // "here is some info '15.4' and true, '15.4' is a number."
		 */
		public static function formatTags(str:String, ... rest):String
		{
			if (str == null)
			{
				return '';
			}

			var len:uint = rest.length;
			var args:Array;
			
			if (len == 1 && rest[0] is Array)
			{
				args = rest[0] as Array;
				len = args.length;
			}
			else
			{
				args = rest;
			}
			
			for (var i:int = 0; i < len; i++)
			{
				str = str.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
			}
			
			return str;
		}
		
		/**
		 *  获取重复指定次数源字符串组成的字符串
		 *
		 *  @param str 源字符串
		 *  @param n 重复次数
		 */
		public static function repeat(str:String, n:int):String
		{
			if (n == 0)
			{
				return "";
			}

			var s:String = str;
			
			for (var i:int = 1; i < n; i++)
			{
				s += str;
			}
			
			return s;
		}
		
		/**
		 * 判断字符串是否以指定前缀开始
		 * 
		 * @param input 字符串
		 * @param prefix 前缀
		 */		
		public static function beginWith(input:String, prefix:String):Boolean
		{			
			return (prefix == input.substring(0, prefix.length));
		}	
		
		/**
		 * 判断字符串是否以指定后缀结束
		 * 
		 * @param input 字符串
		 * @param suffix 后缀
		 */	
		public static function endWith(input:String, suffix:String):Boolean
		{
			return (suffix == input.substring(input.length - suffix.length));
		}
		
		/**
		 * 判断2个字符串是否一致
		 * 
		 * @param s1 字符串1
		 * @param s2 字符串2
		 * @param caseSensitive 是否区分大小写
		 */		
		public static function isEqual(s1:String, s2:String, caseSensitive:Boolean):Boolean
		{
			if (caseSensitive)
			{
				return (s1 == s2);
			}
			else
			{
				return (s1.toUpperCase() == s2.toUpperCase());
			}
		}
	}
}