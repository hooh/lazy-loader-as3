/**
 * Licensed under the MIT License and Creative Commons 3.0 BY-SA
 * 
 * Copyright (c) 2011 The LazyLoader Team
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS CREATIVE COMMONS PUBLIC 
 * LICENSE ("CCPL" OR "LICENSE"). THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. 
 * ANY USE OF THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
 * PROHIBITED.
 * BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO BE BOUND BY THE 
 * TERMS OF THIS LICENSE. TO THE EXTENT THIS LICENSE MAY BE CONSIDERED TO BE A CONTRACT, THE 
 * LICENSOR GRANTS YOU THE RIGHTS CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH 
 * TERMS AND CONDITIONS.
 * 
 * http://creativecommons.org/licenses/by-sa/3.0/legalcode
 *  
 * http://code.google.com/p/lazy-loader-as3
 * 
 * @author João Paulo Marquesini (markezine)
 * 
 */
package me.markezine.lazyloader.events
{
	import flash.events.Event;
	
	/**
	 * A LazyLoaderMediaEvent is dispatched when loading sound or video data using the LazyLoader
	 * or LazyLoaderItem class. There are two types of LazyLoaderMediaEvent: BUFFER_FULL, that is
	 * dispatched by video items when the video can start playing. METADATA_RECEIVED is dispatched 
	 * by video items when the video got metadata and by sound items when it receives the ID3 tags. 
	 */
	public class LazyLoaderMediaEvent extends Event
	{
		/**
		 * Defines the value of the type property of a buffer full event object. 
		 */
		public static const BUFFER_FULL : String = "bufferFull";
		
		/**
		 * Defines the value of the type property of a metadata received event object. 
		 */
		public static const METADATA_RECEIVED : String = "metadataReceived";

		private var _data:Object;
		
		public function LazyLoaderMediaEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function toString():String{
			return formatToString("LazyLoaderMediaEvent", "type", "data", "bubbles", "cancelable"); 
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function clone():Event{
			return new LazyLoaderMediaEvent(type, data, bubbles, cancelable);
		}

		
		/**
		 * Returns the current metadata or ID3 of the item. Please note that this parameter will only be available in the METADATA_RECEIVED event.
		 */
		public function get data():Object
		{
			return _data;
		}

	}
}