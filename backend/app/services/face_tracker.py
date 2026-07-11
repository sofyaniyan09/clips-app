import cv2
import mediapipe as mp
import math

class FaceTrackerService:
    def __init__(self):
        self.mp_face_detection = mp.solutions.face_detection
        
    def get_face_centers(self, video_path: str, target_aspect_ratio=9/16) -> list:
        """
        Analyzes a video and returns a smoothed list of center x-coordinates (in pixels)
        for cropping the video to the target aspect ratio, keeping the face centered.
        Returns a list of dicts: [{'frame': 0, 'crop_x': 100}, ...]
        """
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise Exception(f"Cannot open video {video_path}")
            
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        fps = cap.get(cv2.CAP_PROP_FPS)
        if fps <= 0:
            fps = 30.0
            
        target_width = int(height * target_aspect_ratio)
        if target_width > width:
            target_width = width
            
        centers = []
        raw_centers = []
        
        with self.mp_face_detection.FaceDetection(
            model_selection=1, min_detection_confidence=0.5) as face_detection:
            
            frame_idx = 0
            last_center_x = width // 2
            
            while cap.isOpened():
                success, image = cap.read()
                if not success:
                    break
                    
                image.flags.writeable = False
                image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                results = face_detection.process(image_rgb)
                
                center_x = last_center_x
                if results.detections:
                    detection = results.detections[0]
                    bbox = detection.location_data.relative_bounding_box
                    abs_center_x = int((bbox.xmin + bbox.width / 2) * width)
                    center_x = abs_center_x
                
                crop_x = center_x - (target_width // 2)
                crop_x = max(0, min(crop_x, width - target_width))
                
                time_sec = frame_idx / fps
                raw_centers.append({'frame': frame_idx, 'time': time_sec, 'crop_x': crop_x, 'center_x': center_x})
                last_center_x = center_x
                frame_idx += 1
                
        cap.release()
        
        smoothed_centers = self._smooth_coordinates([r['crop_x'] for r in raw_centers], window_size=30)
        
        final_coords = []
        for i, r in enumerate(raw_centers):
            final_coords.append({
                'frame': r['frame'],
                'time': r['time'],
                'crop_x': int(smoothed_centers[i])
            })
            
        return final_coords

    def _smooth_coordinates(self, coords: list, window_size: int = 30) -> list:
        if not coords:
            return []
        smoothed = []
        for i in range(len(coords)):
            start = max(0, i - window_size // 2)
            end = min(len(coords), i + window_size // 2)
            window = coords[start:end]
            smoothed.append(sum(window) / len(window))
        return smoothed

face_tracker = FaceTrackerService()
