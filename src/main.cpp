#include "imgui-SFML.h"
#include "imgui.h"
#include <SFML/Graphics.hpp>
#include <iostream>

int main() {
  sf::RenderWindow window(sf::VideoMode(640, 480), "SFML Application");
  if (!ImGui::SFML::Init(window)) {
    std::cerr << "ImGui window init error" << std::endl;
    return 1;
  }

  bool circleExists = true;
  float circleRadius = 40.f;

  sf::CircleShape shape;
  shape.setRadius(circleRadius);
  shape.setPosition(100.f, 100.f);
  shape.setFillColor(sf::Color::Cyan);

  sf::Clock deltaClock;
  while (window.isOpen()) {
    sf::Event event;

    while (window.pollEvent(event)) {
      ImGui::SFML::ProcessEvent(window, event);

      if (event.type == sf::Event::Closed)
        window.close();
    }
    ImGui::SFML::Update(window, deltaClock.restart());

    ImGui::Begin("Window title");
    ImGui::Text("Window Text !");
    ImGui::Checkbox("Circle", &circleExists);
    ImGui::SliderFloat("Raduis", &circleRadius, 0.0f, 100.0f);
    ImGui::End();

    window.clear();
    if (circleExists)
      window.draw(shape);
    ImGui::SFML::Render(window);
    window.display();
  }

  ImGui::SFML::Shutdown(window);

  return 0;
}
