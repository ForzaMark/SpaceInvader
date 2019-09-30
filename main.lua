love.graphics.setDefaultFilter('nearest', 'nearest')
player = {}
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.img = love.graphics.newImage('enemie.png')
bulletImg = love.graphics.newImage('bullet.png')
enemiesBulletImg = love.graphics.newImage('enemyBullet.png')
enemyShootSound = love.audio.newSource('enemyShoot.wav', "static")


function checkCollision(enemies, bullets)
  for i, e in ipairs(enemies) do
    for j, b in ipairs(bullets) do
      if b.y <= e.y and b.x > e.x  and (b.x < e.x + e.width) then
        table.remove(enemies, i)
        table.remove(bullets, j)
        if #enemies_controller.enemies == 0 then
          game_win = true
        end
      end
    end
  end
end

function playerCollision(enemies, player)
  for i, enemie in ipairs(enemies) do 
    for j, bullet in ipairs(enemie.bullets) do
      if bullet.y >= player.y and bullet.y < player.y + 3 and bullet.x > player.x and bullet.x < player.x + 55 then
        game_over = true
      end
    end
  end
end

function setBackgroundImage()
  backGroundImg = love.graphics.newImage('background.png')
end

function setGameMusic()
  music = love.audio.newSource('music.wav', "static")
  music:setLooping(true)
  love.audio.play(music)
end

function initializePlayer()  
  player.x = 350
  player.y = 550
  player.img = love.graphics.newImage('player.png')
  player.fireSound = love.audio.newSource('laser.wav', "static")
  player.bullets = {}
  player.cooldown = 20
  player.fire = function()
    if player.cooldown <= 0 then
      love.audio.play(player.fireSound)
      player.cooldown = 20 
      bullet = {}
      bullet.x = player.x + 25
      bullet.y = player.y 
      table.insert(player.bullets, bullet)
    end
  end
end

function enemies_controller:spawnEnemy(x, y)
  spawnedEnemy = {}
  spawnedEnemy.x = x
  spawnedEnemy.y = y
  spawnedEnemy.width = 10 * enemyPictureScale
  spawnedEnemy.height = 10
  spawnedEnemy.speed = 3
  spawnedEnemy.bullets = {}
  spawnedEnemy.cooldown = 20
  spawnedEnemy.movementRate = 20
  table.insert(self.enemies, spawnedEnemy)
end

function enemies_controller.enemies:spawnBullet()
  math.randomseed(os.clock() * 10000000)
  for i, thisEnemy in ipairs(self) do
    randomNumber = math.random(500)
    if thisEnemy.cooldown <= 0 and randomNumber == 400 then
      love.audio.play(enemyShootSound)
      thisEnemy.cooldown = 20
      bullet = {}
      bullet.x = thisEnemy.x + 10
      bullet.y = thisEnemy.y + 20
      table.insert(thisEnemy.bullets, bullet)
    else
      thisEnemy.cooldown = thisEnemy.cooldown - 1
    end
  end
end

function moveEnemyBullets()
  for i, enemies in ipairs(enemies_controller.enemies) do
    for j, bullet in ipairs(enemies.bullets) do
      bullet.y = bullet.y + 5
    end
  end
end

function moveEnemy()
  for i, enemie in ipairs(enemies_controller.enemies)
  do
    enemie.movementRate = enemie.movementRate - 1
    if enemie.movementRate <= 0 then
      enemie.y = enemie.y + 10
      enemie.movementRate = 20
    end
    if enemie.y > 600 then
      table.remove(enemies_controller.enemies, i)
    end
    
    if enemie.y >= player.y then
      game_over = true
    end
  end
end

function love.keyreleased(key)
  if key == 'up' then
    player.fire()
  end
end

function doActionFromKeyBoard()
  if love.keyboard.isDown("right") and player.x + 10 < 753 then
      player.x = player.x + 5 
  end
  if love.keyboard.isDown("left") and player.x - 10 > -3 then
      player.x = player.x - 5 
  end
end

function removeBulletIfOutOfRange()
  for i, bullets in ipairs(player.bullets) 
  do
    if bullets.y < 0 then
      table.remove(bullets, i)
    end
    bullets.y = bullets.y - 10
  end
end

function drawPlayer()
  love.graphics.draw(player.img, player.x, player.y,0 , 5)
end

function drawEnemies()
  for i, enemies in ipairs(enemies_controller.enemies)
  do
    love.graphics.draw(enemies_controller.img, enemies.x, enemies.y, 0, enemyPictureScale)
  end
end

function drawBullets()
  for i, bullets in pairs(player.bullets) 
  do
    love.graphics.draw(bulletImg, bullets.x - 8, bullets.y + 15, 0, 2)
  end
end

function drawEnemieBullets()
    for i, enemie in ipairs(enemies_controller.enemies) do
      for j, bullet in ipairs(enemie.bullets) do
        love.graphics.draw(enemiesBulletImg, bullet.x - 8, bullet.y, 0, 3)
      end
    end
end

function printCountDown()
  if startDelay < 40 then
    love.graphics.draw(love.graphics.newImage('threeCountDown.png'), 320, 200, 0, 3)
  end
  if startDelay > 50 and startDelay < 90 then
    love.graphics.draw(love.graphics.newImage('twoCountDown.png'), 320, 200, 0, 3)
  end
  if startDelay > 90 and startDelay < 130 then
    love.graphics.draw(love.graphics.newImage('oneCountDown.png'), 320, 200, 0, 3)
  end
  if startDelay > 130 and startDelay < 150 then
    love.graphics.draw(love.graphics.newImage('goCountDown.png'), 320, 200, 0, 3)
  end
end

function drawMenu()
  local font = love.graphics.newFont(32)
  love.graphics.setColor(255,255,255)
  local textWHeader = font:getWidth("SpaceInvader")
  
  love.graphics.print("SpaceInvader", font, love.graphics.getWidth() * (1/2) - textWHeader * (1/2), 50)
  
  local fontNext = love.graphics.newFont(24)
  
  local buttonx =  love.graphics.getWidth() * (1/4) 
  local buttony = love.graphics.getHeight()*(1/10)
  
  local textW = font:getWidth("StartGame")
  local textH = font:getHeight("StartGame")
  
  love.graphics.setColor(255,255,255)
  
  love.graphics.draw(love.graphics.newImage('arrowLeft.png'), buttonx, buttony + 100, 0 , 0.7)
  love.graphics.print("- Move Left", fontNext, buttonx + 100, buttony + 110)
  love.graphics.draw(love.graphics.newImage('arrowRight.png'), buttonx, buttony + 200, 0 ,0.7 )
  love.graphics.print("- Move Right", fontNext, buttonx + 100, buttony + 210)
  love.graphics.draw(love.graphics.newImage('arrowUp.png'), buttonx, buttony + 300, 0, 0.7 )
  love.graphics.print("- Fire", fontNext, buttonx + 100, buttony + 310)
  
  love.graphics.print("Press Enter To Start the Game", fontNext, buttonx, buttony + 400)
end

function love.load()
  game_begin = false
  game_win = false
  game_over = false
  enemyPictureScale = 3
  startDelay = 0

  setGameMusic()
  initializePlayer()
  setBackgroundImage()
  
  for i=0, 6 do
    enemies_controller:spawnEnemy(i * 100 + 75,0)
  end
end

function love.update(dt)
  if love.keyboard.isDown("return") then
    game_begin = true
  end
  
  if game_begin then
    player.cooldown = player.cooldown -1
    startDelay = startDelay + 1;
    removeBulletIfOutOfRange()
    
    if startDelay > 150 then
      moveEnemy()
      doActionFromKeyBoard()
      moveEnemyBullets()
    end
    
    for i, enemie in pairs(enemies_controller.enemies) do
      enemies_controller.enemies:spawnBullet()
    end
    playerCollision(enemies_controller.enemies, player)
    checkCollision(enemies_controller.enemies, player.bullets)
  end
end

function love.draw()
  if game_begin then 
    printCountDown()
    love.graphics.draw(backGroundImg)
    love.graphics.setColor(0,0,255)
    drawPlayer()

    love.graphics.setColor(255, 255, 255)
    drawBullets()
    
    love.graphics.setColor(255,255,255)
    drawEnemies()
    
    drawEnemieBullets()
    
    printCountDown()
    
    if game_win then
      love.graphics.draw(love.graphics.newImage('won.png'))
    end
    
    if game_over then
      love.graphics.clear()
      love.graphics.draw(love.graphics.newImage('gameOverPicture.png'))
      return
    end
  else
    drawMenu()
  end
end