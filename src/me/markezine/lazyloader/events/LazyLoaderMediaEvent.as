package me.markezine.lazyloader.events
{
	import flash.events.Event;
	
	public class LazyLoaderMediaEvent extends Event
	{
		public static const BUFFER_FULL : String = "bufferFull";
		public static const METADATA_RECEIVED : String = "metadataReceived";

		private var _data:Object;
		
		public function LazyLoaderMediaEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		override public function toString():String{
			return formatToString("LazyLoaderMediaEvent", "type", "data", "bubbles", "cancelable"); 
		}
		
		override public function clone():Event{
			return new LazyLoaderMediaEvent(type, data, bubbles, cancelable);
		}

		public function get data():Object
		{
			return _data;
		}

	}
}