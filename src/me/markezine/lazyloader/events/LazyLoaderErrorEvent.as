package me.markezine.lazyloader.events
{
	import flash.events.Event;
	
	public class LazyLoaderErrorEvent extends Event
	{
		public static const LAZYLOADER_ERROR:String = "lazyloaderError";
		
		private var _originalEvent:Event;
		
		public function LazyLoaderErrorEvent(type:String, originalEvent:Event, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_originalEvent = originalEvent;
		}
		
		override public function clone():Event{
			return new LazyLoaderErrorEvent(type, originalEvent, bubbles, cancelable);
		}
		
		override public function toString():String{
			return formatToString("LazyLoaderErrorEvent", "type", "originalEvent.type", "bubbles", "cancelable"); 
		}

		public function get originalEvent():Event
		{
			return _originalEvent;
		}

		public function set originalEvent(value:Event):void
		{
			_originalEvent = value;
		}

	}
}