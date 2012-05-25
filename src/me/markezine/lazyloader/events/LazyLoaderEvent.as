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
	import flash.events.ProgressEvent;
	
	public class LazyLoaderEvent extends ProgressEvent
	{
		public static const STARTED_GETTING_SIZE:String = "started_getting_size";
		public static const COMPLETED_GETTING_SIZE:String = "completed_getting_size";
		public static const STARTED_LOADING:String = "started_loading";
		public static const COMPLETE:String = "complete";
		public static const OPEN:String = "open";
		public static const PROGRESS : String = "progress";
		public static const BUFFER_FULL : String = "buffer_full";
		public static const METADATA_RECEIVED : String = "metadata_received";
		
		private var _filesLoaded:uint;
		private var _filesTotal:uint;
		
		private var _partialBytesLoaded:uint;
		private var _partialBytesTotal:uint;
		
		public function LazyLoaderEvent(type:String, bytesLoaded:uint=0, bytesTotal:uint=0,
		filesLoaded:uint=0, filesTotal:uint=0, partialBytesLoaded:uint=0, partialBytesTotal:uint=0,
		bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
			_filesLoaded = filesLoaded;
			_filesTotal = filesTotal;
			_partialBytesLoaded = partialBytesLoaded;
			_partialBytesTotal = partialBytesTotal;
		}
		
		override public function clone():Event{
			return new LazyLoaderEvent(type, bytesLoaded, bytesTotal,
				filesLoaded, filesTotal, partialBytesLoaded, partialBytesTotal,
				bubbles, cancelable);
		}

		public function get filesLoaded():uint
		{
			return _filesLoaded;
		}

		public function get filesTotal():uint
		{
			return _filesTotal;
		}

		public function get partialBytesLoaded():uint
		{
			return _partialBytesLoaded;
		}

		public function get partialBytesTotal():uint
		{
			return _partialBytesTotal;
		}
	}
}