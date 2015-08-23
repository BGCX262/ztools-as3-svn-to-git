package zTools.json
{
	/**
	 * JSON 解码器
	 * 
	 * @author Zivn
	 */
	public class JSONDecoder
	{	
		private var strict:Boolean;
		private var value:*;
		private var tokenizer:JSONTokenizer;
		private var token:JSONToken;
		
		/**
		 * 初始化 JSON 解码器
		 *
		 * @param s JSON 格式字符串
		 * @param strict 是否严格遵守JSON标准
		 */
		public function JSONDecoder(s:String, strict:Boolean)
		{	
			this.strict = strict;
			tokenizer = new JSONTokenizer(s, strict);
			
			nextToken();
			value = parseValue();

			if (strict && nextToken() != null)
			{
				tokenizer.parseError("Unexpected characters left in input stream");
			}
		}
		
		/**
		 * 获取解码后的数据
		 * 
		 */
		public function getValue():*
		{
			return value;
		}

		private function nextToken():JSONToken
		{
			return token = tokenizer.getNextToken();
		}

		private function parseArray():Array
		{
			var a:Array = new Array();
			nextToken();

			if (token.type == JSONTokenType.RIGHT_BRACKET)
			{
				return a;
			}
			else if (!strict && token.type == JSONTokenType.COMMA)
			{
				nextToken();

				if (token.type == JSONTokenType.RIGHT_BRACKET)
				{
					return a;	
				}
				else
				{
					tokenizer.parseError("Leading commas are not supported.  Expecting ']' but found " + token.value);
				}
			}

			while (true)
			{
				a.push(parseValue());
				nextToken();
				
				if (token.type == JSONTokenType.RIGHT_BRACKET)
				{
					return a;
				}
				else if (token.type == JSONTokenType.COMMA)
				{
					nextToken();

					if (!strict)
					{
						if (token.type == JSONTokenType.RIGHT_BRACKET)
						{
							return a;
						}
					}
				}
				else
				{
					tokenizer.parseError("Expecting ] or , but found " + token.value);
				}
			}
            return null;
		}
		
		private function parseObject():Object
		{
			var o:Object = new Object();						
			var key:String
			
			nextToken();
			
			if (token.type == JSONTokenType.RIGHT_BRACE)
			{
				return o;
			}
			else if (!strict && token.type == JSONTokenType.COMMA)
			{
				nextToken();
				
				if (token.type == JSONTokenType.RIGHT_BRACE)
				{
					return o;
				}
				else
				{
					tokenizer.parseError("Leading commas are not supported.  Expecting '}' but found " + token.value);
				}
			}
			
			while (true)
			{
				if (token.type == JSONTokenType.STRING)
				{
					key = String(token.value);					
					nextToken();
					
					if (token.type == JSONTokenType.COLON)
					{	
						nextToken();
						o[key] = parseValue();							
						nextToken();
						
						if (token.type == JSONTokenType.RIGHT_BRACE)
						{
							return o;	
						}
						else if (token.type == JSONTokenType.COMMA)
						{
							nextToken();
							
							if (!strict)
							{
								if (token.type == JSONTokenType.RIGHT_BRACE)
								{
									return o;
								}
							}
						}
						else
						{
							tokenizer.parseError("Expecting } or , but found " + token.value);
						}
					}
					else
					{
						tokenizer.parseError("Expecting : but found " + token.value);
					}
				}
				else
				{	
					tokenizer.parseError("Expecting string but found " + token.value);
				}
			}
			
            return null;
		}

		private function parseValue():Object
		{
			if (token == null)
			{
				tokenizer.parseError("Unexpected end of input");
			}
					
			switch (token.type)
			{
				case JSONTokenType.LEFT_BRACE:
					return parseObject();
					
				case JSONTokenType.LEFT_BRACKET:
					return parseArray();
					
				case JSONTokenType.STRING:
				case JSONTokenType.NUMBER:
				case JSONTokenType.TRUE:
				case JSONTokenType.FALSE:
				case JSONTokenType.NULL:
					return token.value;
					
				case JSONTokenType.NAN:
					if (!strict)
					{
						return token.value;
					}
					else
					{
						tokenizer.parseError("Unexpected " + token.value);
					}

				default:
					tokenizer.parseError("Unexpected " + token.value);
					
			}
			
            return null;
		}
	}
}
