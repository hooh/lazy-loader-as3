package me.markezine.lazyloader.core.metadata
{
	public dynamic class NetStreamMetadata
	{
		public function NetStreamMetadata(object:Object)
		{
			for(var i:String in object){
				var propName:String = i;
				if(this.hasOwnProperty(propName)) propName = "_" + i;
				this[propName] = object[i];
			}
		}
		
		public function get audioChannels():uint{
			return this["audiochannels"];
		}
		
		public function get audioCodecID():String{
			return this["audiocodecid"];
		}
		
		public function get audioDataRate():Number{
			return this["audiodatarate"];
		}
		
		public function get audioDevice():String{
			return this["audiodevice"];
		}
		
		public function get audioInputVolume():String{
			return this["audioinputvolume"];
		}

		
		public function get audioSampleRate():String{
			return this["audiosamplerate"];
		}
		
		public function get creationDate():String{
			return this["creationdate"];
		}
		
		public function get duration():Number{
			return this["_duration"];
		}
		
		public function get FMEversion():Number{
			return this["fmeversion"];
		}
		
		public function get frameRate():Number{
			return this["framerate"] || this["videoframerate"];
		}
		
		public function get height():Number{
			return this["_height"];
		}
		
		public function get lastKeyframeTimestamp():Number{
			return this["lastkeyframetimestamp"]
		}
		
		public function get lastTimestamp():Number{
			return this["lasttimestamp"]
		}
		
		public function get presetName():String{
			return this["presetname"]
		}
		
		public function get videoCodecId():String{
			return this["videocodecid"];
		}
		
		public function get videoDataRate():Number{
			return this["videodatarate"];
		}
		
		public function get videoDevice():Number{
			return this["videodevice"];
		}
		
		public function get videoKeyframeFrequency():Number{
			return this["videokeyframe_frequency"];
		}
		
		public function get width():Number{
			return this["_width"];
		}
	}
}