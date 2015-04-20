class PitchDetector implements AudioEffect
{
  float[] filter= {
    0.0, 0.0
  }; 
  float[] filter3= {
    0.0, 0.0
  }; 
  float[] filter2= {
    0.0, 0.0
  };
  int[] count= {
    0, 0
  };
  int[] zero1= {
    1, 1
  };
  int[] zero2= {
    2, 2
  };
  int[] last2= {
    2, 2
  };
  int[] crossStatus= {
    0, 0
  };
  float[] pitch = {
    220., 220.
  };
  float[] pitchZip = {
    220., 220.
  };
  float[] absLevel = {
    0.0, 0.0
  };
  float[] amplitude = {
    0.0, 0.0
  };
  float[] filtBuf = new float[11025];
  
  
  PitchDetector() {
    for (int i=0; i<filtBuf.length; i++) {
      filtBuf[i]=0.0;
    }
  }
  void process(float[] samp, int ch)
  {
    //    int count=0;
    filtBuf[0]=samp[1];
    for (int i=1; i<samp.length; i++) {
      count[ch]++;
      filter[ch] =(470.0*filter[ch] + (samp[i]*3.0))/471.0;
      filter2[ch] =(8080.0*filter2[ch] + (samp[i]*3.0))/8081.0;
      filter3[ch] =(1900.0*filter3[ch]+filter[ch]*10-filter2[ch]*10)/1901.0;
      filtBuf[i] = (filter[ch]*10-filter2[ch]*10)+filter3[ch];
      //   count++;
      if (amplitude[ch]>0.001) {
        boolean crossed=false;
        if ((filtBuf[i]>=0.01) && (filtBuf[i-1]<0.01))crossed=true;
        //          if((filtBuf[i]<0.0) && (filtBuf[i-1]>=0.0))crossed=true;
        if (crossed  &&crossStatus[ch]==0) {
          zero1[ch]=count[ch];
          crossStatus[ch]=1;
          crossed=false;
        }
        if (crossed &&crossStatus[ch]==1) {
          zero2[ch]=(count[ch]-zero1[ch]);
          if (zero2[ch]>45 && abs(last2[ch]-zero2[ch])<(last2[ch]*0.21)) {
            pitchZip[ch] = (44100.0/( (float)zero2[ch]));
          }
          last2[ch]=zero2[ch];
          //  println(pitchZip[ch]);
          //  println(count[ch] +"  "+zero1[ch]+"   "+ zero2[ch]);
          //  zero2[ch]=0;
          crossStatus[ch]=0;

          crossed=false;
        }
        if (crossed && crossStatus[ch]==3) {
          crossStatus[ch]=0;
        }
      }
      pitch[ch] = (1550*pitch[ch]+pitchZip[ch])/1551;
      if (pitch[ch]<20)pitch[ch]=20;
      float temp = abs(samp[i]);
      if (temp>absLevel[ch]) {
        absLevel[ch]=abs(samp[i]);
      } else {
        absLevel[ch] *= 0.95;
      }
      amplitude[ch]=(90*amplitude[ch]+absLevel[ch])/91;
    }
    count[ch]%=(44100*3);
  }

  void process(float[] mono)
  {
    process(mono, 0);
  }

  void process(float[] left, float[] right)
  {
    process(left, 0);
    process(right, 1);
  }

  float getPitch(int ch) {
    return pitch[ch];
  }
  float getAmplitude(int ch) {
    return amplitude[ch];
  }
  float getPitch() {
    return pitch[0];
  }
  float getAmplitude() {
    return amplitude[0];
  }
}

