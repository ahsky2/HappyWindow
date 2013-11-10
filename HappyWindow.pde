import java.util.*;
 
int imgCount = 30;
int imgIndex = 58;
PImage imgs[] = new PImage[imgCount];

int windowWidth = 1280;
int windowHeight = 720;
int imgWidth = 1280;
int imgHeight = 720;
int popArtWidth = 1280;
int popArtHeight = 720;
int popArtCount = 1;
Vector popArtVector;

int[] savedIndexes = new int[popArtCount];

int[] showIndexes = new int[popArtCount];
int[] showCounts = new int[popArtCount];
int[] showDelayIndexes = new int[popArtCount];
int[] showDelays = new int[popArtCount];
boolean[] isRunnings = new boolean[popArtCount];

boolean isSave = false;
int saveIndex = 0;

int maskCount = 120; // velocity of transition

boolean isRecording = true; // for video
int transitionCount = 30; // # of transition

boolean sketchFullScreen() {
  if(isRecording) {
    return false;
  }
  
  return true;
}

void setup() {
  frameRate(30);
  if(isRecording) {
    size(windowWidth, windowHeight, P2D);
  } else {
    size(displayWidth, displayHeight, P2D);
    println(displayWidth + "," + displayHeight);
  }
  smooth();
  background(255);
  
  for(int i = 0; i < imgCount; i++) {
    imgs[i] = loadImage("PFD_" + imgWidth + "x" + imgHeight + "_" + (i + imgIndex + 100 + "").substring(1) + ".jpg");
    if (imgs[i] == null)  {
      exit();
    }
    imgs[i].resize(popArtWidth, popArtHeight);
  }
  
  popArtVector = new Vector();
  for(int i = 0; i < popArtCount; i++) {
    PopArtCube popArt = new PopArtCube(i * popArtWidth, 0, popArtWidth, popArtHeight);
    
    boolean isSame = true;
    while(isSame) {
      int index = round(random(0, imgCount-1));
      
      isSame = false;
      for(int j = 0; j < i; j++) {
        if(savedIndexes[j] == index) {
          isSame = true;
          break;
        }
      }
      if (!isSame) {
        savedIndexes[i] = index;
        break;
      }
    }
    
    popArt.addImage(imgs[savedIndexes[i]], savedIndexes[i]);
    popArt.addImage(imgs[(savedIndexes[i] + 1) % imgCount], (savedIndexes[i] + 1) % imgCount);
    popArt.setDirection();
    popArt.setMaskCount(maskCount);
    popArtVector.add(popArt);
    
    showIndexes[i] = int(random(0, 600));
    showCounts[i] = 600;
    showDelayIndexes[i] = 0;
    showDelays[i] = int(random(0, 100));;
  }
}

void draw() {
  Iterator iter = popArtVector.iterator();
  int i = 0;
  while (iter.hasNext()) {
    PopArtCube popArt = (PopArtCube)iter.next();
    if (showDelayIndexes[i] < showDelays[i]) {
      showDelayIndexes[i]++;
    } else if (showIndexes[i] < showCounts[i]) {
      showIndexes[i]++;
    } else {
      isRunnings[i] = popArt.transition();
      if (isRunnings[i]) {
      } else {
        
        showDelayIndexes[i] = int(random(0, 100));
        showIndexes[i] = 0;
        showCounts[i] = int(random(400, 600));
        
        if(isRecording) {
          if (popArt.transitionCount < transitionCount) {
            int index;
            if (popArt.transitionCount == transitionCount - 1) {
              index = savedIndexes[i];
            } else {
              index = (popArt.getImgIndex() + 1) % imgCount;
            }
            popArt.addImage(imgs[index], index);
            popArt.setDirection();
          } else {
            popArt.transitionStop();
          }
        } else {
          int index = (popArt.getImgIndex() + 1) % imgCount;
          popArt.addImage(imgs[index], index);
          popArt.setDirection();
        }
      }
    }
  
    popArt.update();
    popArt.display();
    
    i++;
  }
  
  if (isRecording) {
    if (isSave) {
      saveFrame("frames/" +  String.valueOf(10000 + saveIndex).substring(1) + ".jpg");
      saveIndex++;
    }
  }
}

void keyPressed() {
  if (isRecording) {
    if (key == 's' || key == 'S') {
      if (isSave) {
        isSave = false;
        println("Save End");
      } else {
        isSave = true;
        println("Save Start");
      }
    }
  }
}
