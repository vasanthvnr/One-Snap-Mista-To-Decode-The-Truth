package com.example.ai_analyzer.controller;

import com.example.ai_analyzer.service.AnalysisService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/analyze")
@RequiredArgsConstructor
public class AnalysisController {

    private final AnalysisService analysisService;

    @PostMapping("/image")
    public ResponseEntity<Map<String, Object>> analyzeImage(
            @RequestParam("image") MultipartFile image,
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "healthIssues", required = false) String healthIssues ){

        Map<String, Object> response = new HashMap<>();
        try {
            if (image == null || image.isEmpty()) {
                response.put("status", "error");
                response.put("message", "No image provided.");
                return ResponseEntity.badRequest().body(response);
            }

            System.out.println("Received image: " + image.getOriginalFilename());
            System.out.println("Category: " + category);
            System.out.println("Health Issues: " + healthIssues);  

            Map<String, Object> result = analysisService.analyzeImage(image, category, healthIssues);
            response.put("status", "success");
            response.put("data", result);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("status", "error");
            response.put("message", "Failed to analyze image: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

}
