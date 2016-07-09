final int TILE_SIZE = 8;

int map[][];

void setup() {
  size(600, 600);
  noStroke();
  generateMap();
} 

void generateMap() {
  map = new int[width/TILE_SIZE][height/TILE_SIZE];
  randomizeMap();
  cellularAutomata();
  connectAndContainAllRooms();
  while(map[0][0] == 1) {
    openRandomSpace(); 
  }
  invertMap();
  connectAndContainAllRooms();
  while(map[0][0] == 1) {
    openRandomSpace(); 
  }
  invertMap();
  connectAndContainAllRooms();
}

void connectAndContainAllRooms() {
  while (countRooms() > 1) {
    connectRooms(getRooms());
    createBoundaries();
  }
}

void randomizeMap() {
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      map[x][y] = round(random(0.7 + random(-0.15, 0.5)));
    }
  }
}

void invertMap() {
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (map[x][y] == 1) {
        map[x][y] = 0;
      } 
      else {
        map[x][y] = 1;
      }
    }
  }
}

void cellularAutomata() {
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      // >= 5 (8 is good! 5 was orgin val)
      if (emptyNeighbors(x, y, 1) >= 7 + round(random(1))) {
        map[x][y] = 1;
      } else {
        map[x][y] = 0;
      }
    }
  }
}

int emptyNeighbors(int tileX, int tileY, int radius) {
  int emptyNeighbors = 0;
  int x = tileX - radius;
  while (x <= tileX + radius)
  {
    int y = tileY - radius;
    while (y <= tileY + radius)
    {
      if (isWithinMap(x, y) && map[x][y] == 0) {
        emptyNeighbors += 1;
      }
      y += 1;
    }
    x += 1;
  }
  return emptyNeighbors;
}

boolean isWithinMap(int x, int y) {
  return x >= 0 && y >= 0 && x < width/TILE_SIZE && y < height/TILE_SIZE;
}

int countRooms() {
  int roomCount = 0;
  int[][] rooms = new int[width/TILE_SIZE][height/TILE_SIZE];
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (map[x][y] == 0 && rooms[x][y] == 0) {
        roomCount += 1;
        floodFill(x, y, rooms, roomCount);
      }
    }
  }
  return roomCount;
}

int[][] getRooms() {
  int roomCount = 0;
  int[][] rooms = new int[width/TILE_SIZE][height/TILE_SIZE];
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (map[x][y] == 0 && rooms[x][y] == 0) {
        roomCount += 1;
        floodFill(x, y, rooms, roomCount);
      }
    }
  }
  return rooms;
}

void openRandomSpace() {
  PVector randomPoint = pickRandomPoint();
  int[][] rooms = getRooms();

  while (map[int(randomPoint.x)][int(randomPoint.y)] == 0) {
    randomPoint = pickRandomPoint();
  }
  openRandomSpaceHelper(int(randomPoint.x), int(randomPoint.y));
}

void openRandomSpaceHelper(int x, int y) {
  if (isWithinMap(x, y) && map[x][y] == 1) {
    map[x][y] = 0;
    openRandomSpaceHelper(x + 1, y);
    openRandomSpaceHelper(x - 1, y);
    openRandomSpaceHelper(x, y + 1);
    openRandomSpaceHelper(x, y - 1);
  }
}

void floodFill(int x, int y, int[][] rooms, int fill) {
  if (isWithinMap(x, y) && map[x][y] == 0 && rooms[x][y] == 0) {
    rooms[x][y] = fill;
    floodFill(x + 1, y, rooms, fill);
    floodFill(x - 1, y, rooms, fill);
    floodFill(x, y + 1, rooms, fill);
    floodFill(x, y - 1, rooms, fill);
  }
}

void connectRooms(int[][] rooms) {
  // Pick two random points in different rooms
  PVector p1, p2;
  do
  {
    p1 = pickRandomPoint();
  }
  while (rooms[int(p1.x)][int(p1.y)] == 0);
  do
  {
    p2 = pickRandomPoint();
  }
  while (rooms[int(p2.x)][int(p2.y)] == 0 || rooms[int(p2.x)][int(p2.y)] == rooms[int(p1.x)][int(p1.y)]);

  // Get P2 and P2 as close as possible to each other as possible without leaving the rooms they're in
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (rooms[x][y] == rooms[int(p1.x)][int(p1.y)]) {
        if (p1.dist(p2) > p2.dist(new PVector(x, y))) {
          p1 = new PVector(x, y);
        }
      }
    }
  }

  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (rooms[x][y] == rooms[int(p2.x)][int(p2.y)]) {
        if (p1.dist(p2) > p1.dist(new PVector(x, y))) {
          p2 = new PVector(x, y);
        }
      }
    }
  }

  // Dig a tunnel between the two points
  PVector pDig = new PVector(p1.x, p1.y);
  pDig = movePointTowardsPoint(pDig, p2);
  while (pDig != p2 && rooms[int(pDig.x)][int(pDig.y)] == 0)
  {
    map[int(pDig.x)][int(pDig.y)] = 0;
    pDig = movePointTowardsPoint(pDig, p2);
  }
}

PVector movePointTowardsPoint(PVector movePoint, PVector towardsPoint) {
  if (movePoint.x < towardsPoint.x) {
    movePoint.x = movePoint.x + 1;
  } else if (movePoint.x > towardsPoint.x) {
    movePoint.x = movePoint.x - 1;
  } else if (movePoint.y < towardsPoint.y) {
    movePoint.y = movePoint.y + 1;
  } else if (movePoint.y > towardsPoint.y) {
    movePoint.y = movePoint.y - 1;
  }
  return movePoint;
}

PVector pickRandomPoint() {
  return new PVector(int(random(width/TILE_SIZE)), int(random(height/TILE_SIZE)));
}

void createBoundaries() {
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (x == 0 || y == 0 || x == (width/TILE_SIZE)-1 || y == (height/TILE_SIZE)-1) {
        map[x][y] = 1;
      }
    }
  }
}

void draw() {
  for (int x = 0; x < width/TILE_SIZE; x++)
  {
    for (int y = 0; y < height/TILE_SIZE; y++)
    {
      if (map[x][y] == 1) {
        fill(0, 0, 0);
      } else {
        fill(255, 255, 255);
      }
      rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    }
  }
}

void keyPressed() {
  if (key == 'g') {
    generateMap();
  } else if (key == 'i') {
    cellularAutomata();
  } else if (key == 'c') {
    connectAndContainAllRooms();
  } else if (key == 'r') {
    randomizeMap();
  } else if (key == 'o') {
    openRandomSpace();
  } else if (key == 'f') {
    invertMap();
  }
}