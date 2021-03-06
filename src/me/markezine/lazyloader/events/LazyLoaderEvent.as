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
	
	/**
	 * The LazyLoaderEvent is dispatched when normal loading events happen, either in the LazyLoader
	 * class or in the LazyLoaderItem class. There are five types of LazyLoaderEvents: SIZE_COMPLETE
	 * is dispatched when one LazyLoaderItem or a queue in LazyLoader sucessfully get the size of the
	 * files to be loaded. COMPLETE is dispatched when a LazyLoaderItem finishes loading or LazyLoader
	 * finishes a queue. CANCELED is dispatched when a LazyLoaderItem have a close() method called, 
	 * or a LazyLoader have a stop() method called. PROGRESS is called by both when loading progress
	 * happens. OPEN is dispatched when a LazyLoaderItem starts loading.
	 */
	public class LazyLoaderEvent extends ProgressEvent
	{
		
		/**
		 * Defines the value of the type property of a size complete event object. 
		 */
		public static const SIZE_COMPLETE:String = "sizeComplete";
		/**
		 * Defines the value of the type property of a complete event object. 
		 */
		public static const COMPLETE:String = "complete";
		/**
		 * Defines the value of the type property of a loading canceled event object. 
		 */
		public static const CANCELED:String = "canceled";
		/**
		 * Defines the value of the type property of a loading progress event object. 
		 */
		public static const PROGRESS : String = "progress";
		/**
		 * Defines the value of the type property of a loading start event object. 
		 */
		public static const OPEN:String = "open";
		
		public function LazyLoaderEvent(type:String, bytesLoaded:uint=0, bytesTotal:uint=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
		}
		
		/** 
		 * @inheritDoc
		 */
		override public function toString():String{
			return formatToString("LazyLoaderEvent", "type", "bytesLoaded", "bytesTotal", "bubbles", "cancelable"); 
		}
		
		/** 
		 * @inheritDoc
		 */
		override public function clone():Event{
			return new LazyLoaderEvent(type, bytesLoaded, bytesTotal, bubbles, cancelable);
		}
	}
}