using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    [SerializeField] float movementSpeed = 10f; // Speed of movement
    [SerializeField] float lookSpeed = 2f;      // Speed of looking around
    [SerializeField] float sprintMultiplier = 2f; // Sprint speed multiplier

    private float yaw = 0f;
    private float pitch = 0f;
    private bool lockedMouse;

    private void Start()
    {
        lockedMouse = true;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        // Unlock / Lock Mouse
        if (Input.GetKey(KeyCode.Escape))
        {
            if (lockedMouse)
            {
                Cursor.lockState = CursorLockMode.None;
                lockedMouse = false;
                Cursor.visible = true;
            }
            else
            {
                Cursor.lockState = CursorLockMode.Locked;
                lockedMouse = true;
                Cursor.visible = false;
            }
        }

        // Mouse look
        if (lockedMouse)
        {
            yaw += lookSpeed * Input.GetAxis("Mouse X");
            pitch -= lookSpeed * Input.GetAxis("Mouse Y");

            pitch = Mathf.Clamp(pitch, -90f, 90f); // Limit the pitch so you can't flip over
            transform.eulerAngles = new Vector3(pitch, yaw, 0f);

            // Camera movement
            Vector3 move = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
            transform.Translate(move * movementSpeed * Time.deltaTime);

            // Ascend and descend (up and down movement)
            if (Input.GetKey(KeyCode.E)) // Ascend
            {
                transform.Translate(Vector3.up * movementSpeed * Time.deltaTime);
            }
            if (Input.GetKey(KeyCode.Q)) // Descend
            {
                transform.Translate(Vector3.down * movementSpeed * Time.deltaTime);
            }

            // Sprint (increase speed)
            if (Input.GetKey(KeyCode.LeftShift))
            {
                transform.Translate(move * movementSpeed * sprintMultiplier * Time.deltaTime);
            }
        }
    }
}
