
# Smart Room

## i. Introduction to the problem and the solution
The "Smart Room" system is designed to enhance comfort and independence for individuals such as the elderly, infants, and those with limited mobility by automating climate control and air quality management. Utilizing two Arduino Uno microcontrollers in a master-slave configuration, the system efficiently monitors and adjusts the room's temperature and humidity. The master Arduino collects real-time data from a DHT11 sensor and makes decisions to activate or deactivate the air conditioner and humidifier via relays controlled by the slave Arduino. This automation ensures a consistently comfortable and healthy indoor environment without the need for frequent manual intervention.

Key components of the system include relays to control power to the air conditioner and humidifier, an LED indicator for system status, and a manual override button for user control. The DHT11 sensor continuously provides data on temperature and humidity, allowing the master Arduino to maintain optimal conditions by communicating with the slave Arduino to execute necessary actions. This setup offers a user-friendly interface and a practical solution to improve the quality of life for those who need assistance with daily environmental management, showcasing the potential of smart home technology in addressing real-world challenges.


## ii. Hardware design and implementation details
The "Smart Room" hardware design includes key components such as the Arduino Uno microcontroller, which manages system inputs, processes data, and controls operations. Essential elements are the DHT11 sensor for temperature and humidity monitoring, a push button for system control, relays to switch the AC and humidifier, and LEDs for visual feedback. These components create a functional circuit with the Arduino Uno at its core, ensuring effective environmental monitoring and control.

## iii. Software implementation details
The software development for the smart room involves programming the Arduino boards to automate the system. The master Arduino processes data from the DHT11 sensor and uses a push button to select which data (temperature or humidity) to send to the slave Arduino via I2C. The slave Arduino displays this data on the serial monitor while the master uses it to control the relays. The process includes setting up the Arduinos, coding, integrating, and testing functionalities to ensure a reliable and efficient system.

## iv. Test results and performance evaluation
Testing of the Arduino ATmega328P-based automatic temperature and humidity control system demonstrated its effective functionality in various environmental scenarios. The temperature sensor accurately detected temperature changes, triggering the relay to control the AC, turning it on above 30°C and off below 30°C. Similarly, the humidity sensor reliably activated the humidifier when humidity fell below 40% and deactivated it above 40%. The relays responded quickly and precisely to sensor inputs, ensuring efficient control of the AC and humidifier. Overall, the system successfully maintained comfortable environmental conditions through accurate sensor readings and timely device activation.

The automatic control system using Arduino ATmega328P and assembly language showed high performance and fast response times, effectively managing temperature and humidity. However, using assembly language poses challenges in maintenance and updates, and the system lacks a user interface for manual control. To improve the system, it is recommended to adopt a high-level language like C or C++, add a user interface for easier monitoring and control, and enable dynamic adjustment of temperature and humidity thresholds. These enhancements would make the system more flexible, user-friendly, and easier to maintain, ensuring long-term reliability and usability.

## v. Conclusion
The Smart Room system offers an effective solution for maintaining optimal environmental conditions through a master-slave setup using two Arduino Uno microcontrollers. The master Arduino continuously gathers data from the DHT11 sensor to monitor temperature and humidity, making decisions to control the air conditioner and humidifier via the slave Arduino, which operates the relays. This configuration ensures efficient task distribution and reliable climate control. Real-time data monitoring allows the system to maintain a comfortable and healthy environment automatically, while an LED indicator and manual override button provide users with immediate feedback and control. By seamlessly integrating automation with user interaction, the Smart Room enhances living conditions and promotes better air quality, making it a valuable addition to modern homes.

## Images

- Real Circuit
![image](https://github.com/IvanYuantama/SmartRoom-Kelompok10-SSF/assets/123520791/797eb939-a81b-4c61-a053-c4149950ef80)
- Testing Result when Humidity is lower than 40%
![image](https://github.com/IvanYuantama/SmartRoom-Kelompok10-SSF/assets/123520791/84d60310-9359-4859-b117-e1d0ea05a4f3)
- Testing Result when Temperature is lower than 30­°C
![image](https://github.com/IvanYuantama/SmartRoom-Kelompok10-SSF/assets/123520791/a0db83dd-c10e-4247-ba21-770fe3cbc001)

