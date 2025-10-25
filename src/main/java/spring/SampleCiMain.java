package spring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

@SpringBootApplication
public class SampleCiMain {
  
  public static void main(String[] args) {
    SpringApplication.run(SampleCiMain.class, args);
  }
  
}

@RestController
@Slf4j
class PingPongController {
  
  @GetMapping("/ping")
  public String ping() {
    log.info("request: /ping");
    return "pong";
  }
}
