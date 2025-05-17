# Importing Wisper
import whisper
import datetime # to track how long this takes
import os

starttime=datetime.datetime.now()
print(''.join(["Start time is",str(starttime)]))


# model details
runthismodel="large" # tried base.en. It seems to recognize it as a model BUT doesn't want to do the language detection or decoding options steps.
melsforthismodel=128 #need 128 for large model, 80 for smaller ones

# stimulus set: set "folder/" that contains sound files you want to do ASR on
soundfolder="/Users/cogsci-lasrlab1/Downloads/Fiona_stuff/large"

# Loading the Model
model = whisper.load_model(runthismodel) #("base") # let's see how "large" model does SC 12/27/23

# load audio and pad/trim it to fit 30 seconds
audio = whisper.load_audio("/Users/cogsci-lasrlab1/Downloads/Fiona_stuff/base/enM381_senseless.wav")
audio = whisper.pad_or_trim(audio)

# make log-Mel spectrogram and move to the same device as the model
mel = whisper.log_mel_spectrogram(audio,n_mels=melsforthismodel).to(model.device)

# detect the spoken language
_, probs = model.detect_language(mel)
print(f"Detected language: {max(probs, key=probs.get)}")
detectedlanguage = max(probs, key=probs.get)
print(f"Detected language: {detectedlanguage}")

# decode the audio
options = whisper.DecodingOptions(language="en", fp16 = False)
result = whisper.decode(model, mel, options)

# print the recognized text
print(result.text)

def list_files_in_folder(folder_path):
    if os.path.isdir(folder_path):
        files = os.listdir(folder_path)
        output_file_path = f"{folder_path.rstrip('/').replace('/', '_')}{runthismodel}_output.txt"
        print(f"Output_file_path for fcn list_files_in_folder is {output_file_path}")
        # Open the output file for writing
        with open(output_file_path, 'w') as f:
            # Write header to the file
            f.write(f"{'File':<32}{'Actual':<15}{'Predicted'}\n")
            f.write("="*70 + '\n')  # Separator line

            progress=0
            for file_name in files:
                if('.mp3' in file_name or '.wav' in file_name):
                    # Load model outside the loop to avoid reloading it for each file
                    model = whisper.load_model(runthismodel) #("base")
                    audio = whisper.load_audio(os.path.join(folder_path, file_name))
                    audio = whisper.pad_or_trim(audio)
                    mel = whisper.log_mel_spectrogram(audio,n_mels=melsforthismodel).to(model.device)
                    options = whisper.DecodingOptions(language="en", fp16=False) # what if unset to en?
                    result = whisper.decode(model, mel, options)

                    # new bit of code to see if I can detect
##                    _, probs = model.detect_language(mel)
##                    detectedlanguage = max(probs, key=probs.get)
##                    print(f"Detected language: {detectedlanguage}")

##                    # Extract the actual word from the file name
##                    actual_word = file_name[19:-4]

                    # Write formatted output to the file
                    ##f.write(f"{file_name:<32}{result.text}{' '}{detectedlanguage}\n")
                    f.write(f"{file_name:<32}{result.text}\n")

                    # Mirror to cmd line; remove \n so it doesn't double-space
                    print(f"{file_name:<32}{result.text}")
                    progress=progress+1
                    if (progress%50==0):
                        print(''.join(['\n', str(progress), " files completed so far\n"]))
                    
            print(''.join(['\nAll done. ', str(progress), ' files completed.']))
        print(f"Output written to {output_file_path}")

    else:
        print("The provided path for list_files_in_folder is not a directory.")

# Replace 'your_folder_path' with the actual path of the folder you want to open
#folder_path = 'EB21_KT1_MP3/'
folder_path = '/Users/cogsci-lasrlab1/Downloads/Fiona_stuff/large' #"FANN SWS/" #"APstims/" #
list_files_in_folder(folder_path)
print(f"Folder path is {folder_path}")