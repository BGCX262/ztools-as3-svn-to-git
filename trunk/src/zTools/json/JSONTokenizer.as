package zTools.json 
{
	/**
	 * JSON 标记器
	 * 
	 * @author Zivn
	 */
	public class JSONTokenizer 
	{
		private var strict:Boolean;
		private var obj:Object;
		private var jsonString:String;
		private var loc:int;
		private var ch:String;
		private var controlCharsRegExp:RegExp = /[\x00-\x1F]/;
		
		/**
		 * 初始化 JSON 标记器
		 *
		 * @param s JSON 格式字符串
		 * @param strict 是否严格遵守JSON标准
		 */
		public function JSONTokenizer(s:String, strict:Boolean)
		{
			jsonString = s;
			this.strict = strict;
			loc = 0;

			nextChar();
		}
		
		/**
		 * 获取 JSON 字符串的下一个标记
		 * 
		 */
		public function getNextToken():JSONToken
		{
			var token:JSONToken = new JSONToken();

			skipIgnored();

			switch (ch)
			{	
				case '{':
					token.type = JSONTokenType.LEFT_BRACE;
					token.value = '{';
					nextChar();
					break
					
				case '}':
					token.type = JSONTokenType.RIGHT_BRACE;
					token.value = '}';
					nextChar();
					break
					
				case '[':
					token.type = JSONTokenType.LEFT_BRACKET;
					token.value = '[';
					nextChar();
					break
					
				case ']':
					token.type = JSONTokenType.RIGHT_BRACKET;
					token.value = ']';
					nextChar();
					break
				
				case ',':
					token.type = JSONTokenType.COMMA;
					token.value = ',';
					nextChar();
					break
					
				case ':':
					token.type = JSONTokenType.COLON;
					token.value = ':';
					nextChar();
					break;
					
				case 't':
					var possibleTrue:String = "t" + nextChar() + nextChar() + nextChar();
					
					if (possibleTrue == "true")
					{
						token.type = JSONTokenType.TRUE;
						token.value = true;
						nextChar();
					}
					else
					{
						parseError("Expecting 'true' but found " + possibleTrue);
					}
					
					break;
					
				case 'f':
					var possibleFalse:String = "f" + nextChar() + nextChar() + nextChar() + nextChar();
					
					if (possibleFalse == "false")
					{
						token.type = JSONTokenType.FALSE;
						token.value = false;
						nextChar();
					}
					else
					{
						parseError("Expecting 'false' but found " + possibleFalse);
					}
					
					break;
					
				case 'n':
					var possibleNull:String = "n" + nextChar() + nextChar() + nextChar();
					
					if (possibleNull == "null")
					{
						token.type = JSONTokenType.NULL;
						token.value = null;
						nextChar();
					}
					else
					{
						parseError("Expecting 'null' but found " + possibleNull);
					}
					
					break;
					
				case 'N':
					var possibleNaN:String = "N" + nextChar() + nextChar();
					
					if (possibleNaN == "NaN")
					{
						token.type = JSONTokenType.NAN;
						token.value = NaN;
						nextChar();
					}
					else
					{
						parseError("Expecting 'NaN' but found " + possibleNaN);
					}
					
					break;
					
				case '"':
					token = readString();
					break;
					
				default: 
					if (isDigit(ch) || ch == '-')
					{
						token = readNumber();
					}
					else if (ch == '')
					{
						return null;
					}
					else
					{		
						parseError("Unexpected " + ch + " encountered");
					}
			}
			
			return token;
		}

		private function readString():JSONToken
		{
			var quoteIndex:int = loc;
			
			do
			{
				quoteIndex = jsonString.indexOf("\"", quoteIndex);
				
				if (quoteIndex >= 0)
				{					
					var backspaceCount:int = 0;
					var backspaceIndex:int = quoteIndex - 1;
					
					while (jsonString.charAt(backspaceIndex) == "\\")
					{
						backspaceCount++;
						backspaceIndex--;
					}
					
					if (backspaceCount % 2 == 0)
					{
						break;
					}
					
					quoteIndex++;
				}
				else
				{
					parseError("Unterminated string literal");
				}
				
			} 
			while (true);
			
			var token:JSONToken = new JSONToken();
			token.type = JSONTokenType.STRING;
			token.value = unescapeString(jsonString.substr(loc, quoteIndex - loc));
			
			loc = quoteIndex + 1;
			nextChar();
			
			return token;
		}
		
		/**
		 * 转换所有转义过的字符为原始字符
		 *
		 * @param input 转义后的字符串
		 */
		public function unescapeString(input:String):String
		{
			if (strict && controlCharsRegExp.test(input))
			{
				parseError("String contains unescaped control character (0x00-0x1F)");
			}
			
			var result:String = "";
			var backslashIndex:int = 0;
			var nextSubstringStartPosition:int = 0;
			var len:int = input.length;
			
			do
			{
				backslashIndex = input.indexOf('\\', nextSubstringStartPosition);
				
				if (backslashIndex >= 0)
				{
					result += input.substr(nextSubstringStartPosition, backslashIndex - nextSubstringStartPosition);					
					nextSubstringStartPosition = backslashIndex + 2;
					
					var afterBackslashIndex:int = backslashIndex + 1;
					var escapedChar:String = input.charAt(afterBackslashIndex);
					
					switch (escapedChar)
					{						
						case '"': result += '"'; break;
						case '\\': result += '\\'; break;
						case 'n': result += '\n'; break;
						case 'r': result += '\r'; break;
						case 't': result += '\t'; break;						
						case 'u':							
							var hexValue:String = "";
							
							if (nextSubstringStartPosition + 4 > len)
							{
								parseError("Unexpected end of input.  Expecting 4 hex digits after \\u.");
							}
							
							for (var i:int = nextSubstringStartPosition; i < nextSubstringStartPosition + 4; i++)
							{
								var possibleHexChar:String = input.charAt(i);
								
								if (!isHexDigit(possibleHexChar))
								{
									parseError("Excepted a hex digit, but found: " + possibleHexChar);
								}
								
								hexValue += possibleHexChar;
							}
							
							result += String.fromCharCode(parseInt(hexValue, 16));
							nextSubstringStartPosition += 4;
							
							break;
						
						case 'f': result += '\f'; break;
						case '/': result += '/'; break;
						case 'b': result += '\b'; break;
						default: result += '\\' + escapedChar;
					}
				}
				else
				{
					result += input.substr(nextSubstringStartPosition);
					break;
				}
				
			} 
			while (nextSubstringStartPosition < len);
			
			return result;
		}
		
		private function readNumber():JSONToken
		{
			var input:String = "";

			if (ch == '-')
			{
				input += '-';
				nextChar();
			}
			
			if (!isDigit(ch))
			{
				parseError("Expecting a digit");
			}
			
			if (ch == '0')
			{
				input += ch;
				nextChar();
				
				if (isDigit(ch))
				{
					parseError("A digit cannot immediately follow 0");
				}
				else if (!strict && ch == 'x')
				{
					input += ch;
					nextChar();
					
					if (isHexDigit(ch))
					{
						input += ch;
						nextChar();
					}
					else
					{
						parseError("Number in hex format require at least one hex digit after \"0x\"");	
					}
					
					while (isHexDigit(ch))
					{
						input += ch;
						nextChar();
					}
				}
			}
			else
			{
				while (isDigit(ch))
				{
					input += ch;
					nextChar();
				}
			}
			
			if (ch == '.')
			{
				input += '.';
				nextChar();
				
				if (!isDigit(ch))
				{
					parseError("Expecting a digit");
				}
				
				while (isDigit(ch))
				{
					input += ch;
					nextChar();
				}
			}
			
			if (ch == 'e' || ch == 'E')
			{
				input += "e"
				nextChar();

				if (ch == '+' || ch == '-')
				{
					input += ch;
					nextChar();
				}
				
				if (!isDigit(ch))
				{
					parseError("Scientific notation number needs exponent value");
				}
							
				while (isDigit(ch))
				{
					input += ch;
					nextChar();
				}
			}
			
			var num:Number = Number(input);
			
			if (isFinite(num) && !isNaN(num))
			{
				var token:JSONToken = new JSONToken();
				token.type = JSONTokenType.NUMBER;
				token.value = num;
				return token;
			}
			else
			{
				parseError("Number " + num + " is not valid!");
			}
			
            return null;
		}

		private function nextChar():String
		{
			return ch = jsonString.charAt(loc++);
		}

		private function skipIgnored():void
		{
			var originalLoc:int;

			do
			{
				originalLoc = loc;
				skipWhite();
				skipComments();
			}
			while (originalLoc != loc);
		}

		private function skipComments():void
		{
			if (ch == '/')
			{
				nextChar();
				
				switch (ch)
				{
					case '/':						
						do
						{
							nextChar();
						}
						while (ch != '\n' && ch != '')
						
						nextChar();						
						break;
					
					case '*':
						nextChar();
						
						while (true)
						{
							if (ch == '*')
							{
								nextChar();
								
								if (ch == '/')
								{
									nextChar();
									break;
								}
							}
							else
							{
								nextChar();
							}
							
							if (ch == '')
							{
								parseError("Multi-line comment not closed");
							}
						}

						break;
					
					default:
						parseError("Unexpected " + ch + " encountered (expecting '/' or '*')");
				}
			}
			
		}

		private function skipWhite():void
		{	
			while (isWhiteSpace(ch))
			{
				nextChar();
			}			
		}

		private function isWhiteSpace(ch:String):Boolean
		{
			if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r')
			{
				return true;
			}
			else if (!strict && ch.charCodeAt(0) == 160)
			{
				return true;
			}
			
			return false;
		}

		private function isDigit(ch:String):Boolean
		{
			return (ch >= '0' && ch <= '9');
		}

		private function isHexDigit(ch:String):Boolean
		{
			return (isDigit(ch) || (ch >= 'A' && ch <= 'F') || (ch >= 'a' && ch <= 'f'));
		}
	
		/**
		 * 引起一个解析错误
		 *
		 * @param message 错误信息
		 */
		public function parseError(message:String):void
		{
			throw new JSONParseError(message, loc, jsonString);
		}
	}
	
}
